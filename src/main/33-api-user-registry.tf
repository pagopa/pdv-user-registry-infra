locals {
  user_registry_api_name         = format("%s-user-registry-api", local.project)
  user_registry_stage_name       = "v1"
  list_user_registry_key_to_name = [for n in var.user_registry_plans : "'${aws_api_gateway_api_key.main[n.key_name].id}':'${n.key_name}'"]
  user_registry_log_group_name   = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.user_registry.id}/${local.user_registry_stage_name}"
}

resource "aws_api_gateway_rest_api" "user_registry" {
  name           = local.user_registry_api_name
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
    types = ["REGIONAL"]
  }

  tags = { Name = local.user_registry_api_name }
}

resource "aws_api_gateway_deployment" "user_registry" {
  rest_api_id = aws_api_gateway_rest_api.user_registry.id
  # stage_name  = local.user_registry_stage_name

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.user_registry.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "user_registry" {
  name              = local.user_registry_log_group_name
  retention_in_days = var.apigw_execution_logs_retention

  tags = { Name = local.user_registry_api_name }

}
resource "aws_api_gateway_stage" "user_registry" {
  deployment_id         = aws_api_gateway_deployment.user_registry.id
  rest_api_id           = aws_api_gateway_rest_api.user_registry.id
  stage_name            = local.user_registry_stage_name
  cache_cluster_size    = 0.5 #why is this needed ?
  documentation_version = aws_api_gateway_documentation_version.main.version

  dynamic "access_log_settings" {
    for_each = var.apigw_access_logs_enable ? ["dymmy"] : []
    content {
      destination_arn = aws_cloudwatch_log_group.user_registry.arn
      #todo: find a better way to represent this log format.
      format = "{ \"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
    }
  }
}

resource "aws_api_gateway_method_settings" "user_registry" {
  rest_api_id = aws_api_gateway_rest_api.user_registry.id
  stage_name  = local.user_registry_stage_name
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
}

resource "aws_api_gateway_usage_plan" "user_registry" {
  for_each    = local.api_key_list
  name        = format("%s-api-plan-%s", local.project, lower(each.key))
  description = "Usage plan for main user_registry apis"

  api_stages {
    api_id = aws_api_gateway_rest_api.user_registry.id
    stage  = aws_api_gateway_stage.user_registry.stage_name

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
}

resource "aws_api_gateway_usage_plan_key" "user_registry" {
  for_each      = local.api_key_list
  key_id        = aws_api_gateway_api_key.main[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.user_registry[each.key].id
}

resource "aws_apigatewayv2_api_mapping" "user_registry" {
  count           = var.apigw_custom_domain_create ? 1 : 0
  api_id          = aws_api_gateway_rest_api.user_registry.id
  stage           = local.user_registry_stage_name
  domain_name     = aws_api_gateway_domain_name.main[0].domain_name
  api_mapping_key = format("user-registry/%s", aws_api_gateway_stage.user_registry.stage_name)
}

## WAF association
resource "aws_wafv2_web_acl_association" "user_registry" {
  web_acl_arn  = aws_wafv2_web_acl.main.arn
  resource_arn = "arn:aws:apigateway:${var.aws_region}::/restapis/${aws_api_gateway_rest_api.user_registry.id}/stages/${aws_api_gateway_stage.user_registry.stage_name}"
}

output "user_registry_api_keys" {
  value     = { for k in keys(local.api_key_list) : k => aws_api_gateway_usage_plan_key.user_registry[k].value }
  sensitive = true
}

locals {
  user_registry_api_ids = { for k in keys(local.api_key_list) : k => aws_api_gateway_usage_plan.user_registry[k].id }
}

output "user_registryinvoke_url" {
  value = try(aws_api_gateway_deployment.user_registry.invoke_url, null)
}

## Alarms
### 4xx
module "api_user_registry_4xx_error_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "~> 3.0"

  actions_enabled     = var.env_short == "p" ? true : false
  alarm_name          = "high-4xx-rate-"
  alarm_description   = "Api User registry error rate has exceeded 5%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 200
  period              = 300
  unit                = "Count"
  datapoints_to_alarm = 1

  namespace   = "AWS/ApiGateway"
  metric_name = "4XXError"
  statistic   = "Sum"

  dimensions = {
    "${local.user_registry_api_name}" = {
      ApiName = local.user_registry_api_name
      Stage   = local.user_registry_stage_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

### 5xx
module "api_user_registry_5xx_error_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "~> 3.0"

  actions_enabled     = var.env_short == "p" ? true : false
  alarm_name          = "high-5xx-rate-"
  alarm_description   = "Api user registry error rate has exceeded 5%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 20
  threshold           = 5
  period              = 300
  unit                = "Count"
  datapoints_to_alarm = 2

  namespace   = "AWS/ApiGateway"
  metric_name = "5XXError"
  statistic   = "Sum"

  dimensions = {
    "${local.user_registry_api_name}" = {
      ApiName = local.user_registry_api_name
      Stage   = local.user_registry_stage_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

### throttling (exceeded throttle limit)
module "log_filter_throttle_limit_user_registry" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "~> 3.0"

  name = format("%s-metric-throttle-rate-limit", local.user_registry_api_name)

  log_group_name = local.user_registry_log_group_name

  pattern = "exceeded throttle limit"

  metric_transformation_namespace = "ErrorCount"
  metric_transformation_name      = format("%s-namespace", local.user_registry_api_name)

  depends_on = [
    aws_cloudwatch_log_group.user_registry
  ]

}

module "api_user_registry_throttle_limit_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 3.0"

  actions_enabled     = var.env_short == "p" ? true : false
  alarm_name          = format("high-rate-limit-throttle-%s", local.user_registry_api_name)
  alarm_description   = "Throttle rate limit too high."
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 2
  threshold           = 20
  period              = 300
  #unit                = "Count"

  namespace   = "ErrorCount"
  metric_name = format("%s-namespace", local.user_registry_api_name)
  statistic   = "Sum"

  alarm_actions = [aws_sns_topic.alarms.arn]

  depends_on = [
    module.log_filter_throttle_limit_user_registry
  ]
}

locals {
  latency_threshold = 2000
}

module "api_user_registry_low_latency_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "~> 3.0"

  actions_enabled     = var.env_short == "p" ? true : false
  alarm_name          = "low-latency-"
  alarm_description   = format("The Api responds in more than %s ms.", local.latency_threshold)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = local.latency_threshold
  period              = 300
  unit                = "Count"
  datapoints_to_alarm = 1

  namespace   = "AWS/ApiGateway"
  metric_name = "Latency"
  statistic   = "Maximum"

  dimensions = {
    "${local.user_registry_api_name}" = {
      ApiName = local.user_registry_api_name
      Stage   = local.user_registry_stage_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}