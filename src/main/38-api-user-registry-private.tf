locals {
  user_registry_api_private_name       = format("%s-user-registry-api-private", local.project)
  user_registry_stage_private_name     = "private-v1"
  user_registry_log_group_private_name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.user_registry_private.id}/${local.user_registry_stage_private_name}"
}

resource "aws_api_gateway_rest_api" "user_registry_private" {
  name           = local.user_registry_api_private_name
  api_key_source = "HEADER"

  body = templatefile("./api/ms_user_registry/api-docs.tpl.json",
    {
      uri           = format("http://%s:%s", module.nlb.lb_dns_name, var.container_port_user_registry),
      connection_id = aws_api_gateway_vpc_link.apigw.id
      write_request_template = chomp(templatefile("./api/velocity_request_template_write.tpl",
        {
          list_key_to_name = join(",", local.list_user_registry_key_to_name)
      }))
      responses = file("./api/ms_user_registry/status_code_mapping.tpl.json")
    }
  )

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [var.oi_integration_vpc_endpoint_id]
  }

  tags = { Name = local.user_registry_api_private_name }
}

data "aws_iam_policy_document" "user_registry_private_policy" {
  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.user_registry_private.execution_arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"
      values   = [var.oi_integration_vpc_endpoint_id]
    }
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.user_registry_private.execution_arn}/*"]

  }
}
resource "aws_api_gateway_rest_api_policy" "user_registry_private_policy" {
  rest_api_id = aws_api_gateway_rest_api.user_registry_private.id
  policy      = data.aws_iam_policy_document.user_registry_private_policy.json
}

resource "aws_api_gateway_deployment" "user_registry_private" {
  rest_api_id = aws_api_gateway_rest_api.user_registry_private.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.user_registry_private.*))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_rest_api_policy.user_registry_private_policy]
}

resource "aws_cloudwatch_log_group" "user_registry_private" {
  name              = local.user_registry_log_group_private_name
  retention_in_days = var.apigw_execution_logs_retention

  tags = { Name = local.user_registry_api_private_name }

}
resource "aws_api_gateway_stage" "user_registry_private" {
  deployment_id      = aws_api_gateway_deployment.user_registry_private.id
  rest_api_id        = aws_api_gateway_rest_api.user_registry_private.id
  stage_name         = local.user_registry_stage_private_name
  cache_cluster_size = 0.5 #why is this needed ?
  # documentation_version = aws_api_gateway_documentation_version.main.version
  xray_tracing_enabled = true

  dynamic "access_log_settings" {
    for_each = var.apigw_access_logs_enable ? ["dymmy"] : []
    content {
      destination_arn = aws_cloudwatch_log_group.user_registry_private.arn
      #todo: find a better way to represent this log format.
      format = "{ \"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
    }
  }
}

resource "aws_api_gateway_method_settings" "user_registry_private" {
  rest_api_id = aws_api_gateway_rest_api.user_registry_private.id
  stage_name  = local.user_registry_stage_private_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = var.apigw_data_trace_enabled
    logging_level      = "ERROR"
    #todo.
    # Limit the rate of calls to prevent abuse and unwanted charges
    #throttling_rate_limit  = 100
    #throttling_burst_limit = 50
  }

  depends_on = [aws_api_gateway_stage.user_registry_private]
}

resource "aws_api_gateway_usage_plan" "user_registry_private" {
  for_each    = local.api_key_list
  name        = format("%s-api-private-plan-%s", local.project, lower(each.key))
  description = "Usage plan for main user_registry_private apis"

  api_stages {
    api_id = aws_api_gateway_rest_api.user_registry_private.id
    stage  = aws_api_gateway_stage.user_registry_private.stage_name


    dynamic "throttle" {
      for_each = each.value.method_throttle
      content {
        path        = throttle.value.path
        burst_limit = throttle.value.burst_limit
        rate_limit  = throttle.value.rate_limit
      }
    }

  }

  /*
  quota_settings {
    limit  = 20
    offset = 2
    period = "WEEK"
  }
  */
  throttle_settings {
    burst_limit = each.value.burst_limit
    rate_limit  = each.value.rate_limit
  }
  depends_on = [aws_api_gateway_stage.user_registry_private]

}

resource "aws_api_gateway_usage_plan_key" "user_registry_private" {
  for_each      = local.api_key_list
  key_id        = aws_api_gateway_api_key.main[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.user_registry_private[each.key].id
}

resource "aws_api_gateway_usage_plan_key" "user_registry_private_additional" {
  for_each      = { for k in local.additional_keys : k.key => k }
  key_id        = aws_api_gateway_api_key.additional[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.user_registry_private[each.value.plan].id

  depends_on = [
    aws_api_gateway_api_key.additional
  ]
}

## WAF association
resource "aws_wafv2_web_acl_association" "user_registry_private" {
  web_acl_arn  = aws_wafv2_web_acl.main.arn
  resource_arn = "arn:aws:apigateway:${var.aws_region}::/restapis/${aws_api_gateway_rest_api.user_registry_private.id}/stages/${aws_api_gateway_stage.user_registry_private.stage_name}"
}

output "user_registry_private_invoke_url" {
  value = try(aws_api_gateway_deployment.user_registry_private.invoke_url, null)
}

## Alarms
### 4xx
module "api_user_registry_private_4xx_error_alarm" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-cloudwatch.git//modules/metric-alarms-by-multiple-dimensions?ref=60cf981e0f1ae033699e5b274440867e48289967"

  actions_enabled     = true
  alarm_name          = "high-4xx-rate-"
  alarm_description   = "Api User registry private error rate has exceeded the threshold."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = var.alarm_4xx_threshold
  period              = 300
  unit                = "Count"
  datapoints_to_alarm = 1

  namespace   = "AWS/ApiGateway"
  metric_name = "4XXError"
  statistic   = "Sum"

  dimensions = {
    "${local.user_registry_api_private_name}" = {
      ApiName = local.user_registry_api_private_name
      Stage   = local.user_registry_stage_private_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

### 5xx
module "api_user_registry_private_5xx_error_alarm" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-cloudwatch.git//modules/metric-alarms-by-multiple-dimensions?ref=60cf981e0f1ae033699e5b274440867e48289967"

  alarm_name          = "high-5xx-rate-"
  alarm_description   = "${local.runbook_title} ${local.runbook_url} Api user registry private error rate has exceeded the threshold."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  unit                = "Count"
  datapoints_to_alarm = 1

  namespace   = "AWS/ApiGateway"
  metric_name = "5XXError"
  statistic   = "Sum"

  dimensions = {
    "${local.user_registry_api_private_name}" = {
      ApiName = local.user_registry_api_private_name
      Stage   = local.user_registry_stage_private_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

### throttling (exceeded throttle limit)
module "log_filter_throttle_limit_user_registry_private" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-cloudwatch.git//modules/log-metric-filter?ref=60cf981e0f1ae033699e5b274440867e48289967"
  name   = format("%s-metric-throttle-rate-limit", local.user_registry_api_private_name)

  log_group_name = local.user_registry_log_group_private_name

  pattern = "exceeded throttle limit"

  metric_transformation_namespace = "ErrorCount"
  metric_transformation_name      = format("%s-namespace", local.user_registry_api_private_name)

  depends_on = [
    aws_cloudwatch_log_group.user_registry_private
  ]

}

module "api_user_registry_private_throttle_limit_alarm" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-cloudwatch.git//modules/metric-alarm?ref=60cf981e0f1ae033699e5b274440867e48289967"

  actions_enabled     = var.env_short == "p" ? true : false
  alarm_name          = format("high-rate-limit-throttle-%s", local.user_registry_api_private_name)
  alarm_description   = "Throttle rate limit too high."
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 2
  threshold           = 20
  period              = 300
  #unit                = "Count"

  namespace   = "ErrorCount"
  metric_name = format("%s-namespace", local.user_registry_api_private_name)
  statistic   = "Sum"

  alarm_actions = [aws_sns_topic.alarms.arn]

  depends_on = [
    module.log_filter_throttle_limit_user_registry_private
  ]
}

module "api_user_registry_private_low_latency_alarm" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-cloudwatch.git//modules/metric-alarms-by-multiple-dimensions?ref=60cf981e0f1ae033699e5b274440867e48289967"

  actions_enabled     = var.env_short == "p" ? true : false
  alarm_name          = "low-latency-"
  alarm_description   = format("The Api responds in more than %s ms.", local.latency_threshold)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = local.latency_threshold
  period              = 300
  # unit                = "Count"
  datapoints_to_alarm = 1

  namespace   = "AWS/ApiGateway"
  metric_name = "Latency"
  statistic   = "Average"

  dimensions = {
    "${local.user_registry_api_private_name}" = {
      ApiName = local.user_registry_api_private_name
      Stage   = local.user_registry_stage_private_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}