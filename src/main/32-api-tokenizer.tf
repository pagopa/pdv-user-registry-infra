locals {
  tokenizer_api_name         = format("%s-tokenizer-api", local.project)
  tokenizer_stage_name       = "v1"
  list_tokenizer_key_to_name = [for n in var.api_keys_tokenizer : "'${aws_api_gateway_api_key.main[n].id}':'${aws_api_gateway_api_key.main[n].name}'"]
  tokenizer_log_group_name   = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.tokenizer.id}/${local.tokenizer_stage_name}"
}

resource "aws_api_gateway_rest_api" "tokenizer" {
  name           = local.tokenizer_api_name
  api_key_source = "HEADER"

  body = templatefile("./api/ms_tokenizer/api-docs.tpl.json",
    {
      uri           = format("http://%s", module.nlb.lb_dns_name),
      connection_id = aws_api_gateway_vpc_link.apigw.id
      write_request_template = chomp(templatefile("./api/velocity_request_template_write.tpl",
        {
          list_key_to_name = join(",", local.list_tokenizer_key_to_name)
      }))
    }
  )

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = { Name = local.tokenizer_api_name }
}

resource "aws_api_gateway_deployment" "tokenizer" {
  rest_api_id = aws_api_gateway_rest_api.tokenizer.id
  # stage_name  = local.tokenizer_stage_name

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.tokenizer.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "tokenizer" {
  name              = local.tokenizer_log_group_name
  retention_in_days = 7

  tags = { Name = local.tokenizer_api_name }
}
resource "aws_api_gateway_stage" "tokenizer" {
  deployment_id      = aws_api_gateway_deployment.tokenizer.id
  rest_api_id        = aws_api_gateway_rest_api.tokenizer.id
  stage_name         = local.tokenizer_stage_name
  cache_cluster_size = 0.5 #why is this needed ?

  dynamic "access_log_settings" {
    for_each = var.apigw_access_logs_enable ? ["dymmy"] : []
    content {
      destination_arn = aws_cloudwatch_log_group.tokenizer.arn
      #todo: find a better way to represent this log format.
      format = "{ \"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
    }
  }
}

resource "aws_api_gateway_method_settings" "tokenizer" {
  rest_api_id = aws_api_gateway_rest_api.tokenizer.id
  stage_name  = local.tokenizer_stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "ERROR"
    #todo.
    # Limit the rate of calls to prevent abuse and unwanted charges
    #throttling_rate_limit  = 100
    #throttling_burst_limit = 50
  }
}

resource "aws_api_gateway_usage_plan" "tokenizer" {
  name        = format("%s-api-tokenizer", local.project)
  description = "Usage plan for tokenizer apis"

  api_stages {
    api_id = aws_api_gateway_rest_api.tokenizer.id
    stage  = aws_api_gateway_stage.tokenizer.stage_name

    dynamic "throttle" {
      for_each = var.api_tokenizer_throttling.method_throttle
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

  #TODO: tune this settings
  throttle_settings {
    burst_limit = var.api_tokenizer_throttling.burst_limit
    rate_limit  = var.api_tokenizer_throttling.rate_limit
  }
}

resource "aws_api_gateway_usage_plan_key" "tokenizer" {
  for_each      = toset(var.api_keys_tokenizer)
  key_id        = aws_api_gateway_api_key.main[each.value].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.tokenizer.id
}


## Mapping api tokenizer with apigw custom domain.
resource "aws_api_gateway_base_path_mapping" "tokenizer" {
  count       = var.apigw_custom_domain_create ? 1 : 0
  api_id      = aws_api_gateway_rest_api.tokenizer.id
  stage_name  = local.tokenizer_stage_name
  domain_name = aws_api_gateway_domain_name.main[0].domain_name
  base_path   = "tokenizer"
}

## WAF association
resource "aws_wafv2_web_acl_association" "tokenizer" {
  web_acl_arn  = aws_wafv2_web_acl.main.arn
  resource_arn = "arn:aws:apigateway:${var.aws_region}::/restapis/${aws_api_gateway_rest_api.tokenizer.id}/stages/${aws_api_gateway_stage.tokenizer.stage_name}"
}


output "tokenizer_api_keys" {
  value     = { for k in var.api_keys_tokenizer : k => aws_api_gateway_usage_plan_key.tokenizer[k].value }
  sensitive = true
}

output "tokenizer_api_ids" {
  value = { for k in var.api_keys_tokenizer : k => aws_api_gateway_usage_plan_key.tokenizer[k].id }
}

/*
//The API Gateway endpoint
output "api_gateway_endpoint" {
  value = format("https://", aws_api_gateway_domain_name.main.domain_name)
}
*/
output "tokenizerinvoke_url" {
  value = aws_api_gateway_deployment.tokenizer.invoke_url
}


## Alarms tokenizer
### 5xx
module "api_tokenizer_5xx_error_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "~> 3.0"

  actions_enabled     = var.env_short == "p" ? true : false
  alarm_name          = "high-5xx-rate-"
  alarm_description   = "Api tokenizer error rate has exceeded 5%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 5
  period              = 60
  unit                = "Count"
  datapoints_to_alarm = 2

  namespace   = "AWS/ApiGateway"
  metric_name = "5XXError"
  statistic   = "Average"

  dimensions = {
    "${local.tokenizer_api_name}" = {
      ApiName = local.tokenizer_api_name
      Stage   = local.tokenizer_stage_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

# Alarms
### 4xx
module "api_tokenizer_4xx_error_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "~> 3.0"

  actions_enabled     = var.env_short == "p" ? true : false
  alarm_name          = "high-4xx-rate-"
  alarm_description   = "Api tokenizer error rate has exceeded 5%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 5
  period              = 60
  unit                = "Count"
  datapoints_to_alarm = 1

  namespace   = "AWS/ApiGateway"
  metric_name = "4XXError"
  statistic   = "Average"

  dimensions = {
    "${local.tokenizer_api_name}" = {
      ApiName = local.tokenizer_api_name
      Stage   = local.tokenizer_stage_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

# Alarms
### throttling (exceeded throttle limit)
module "log_filter_throttle_limit_tokenizer" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "~> 3.0"

  name = format("%s-metric-throttle-rate-limit", local.tokenizer_api_name)

  log_group_name = local.tokenizer_log_group_name

  pattern = "exceeded throttle limit"

  metric_transformation_namespace = "ErrorCount"
  metric_transformation_name      = format("%s-namespace", local.tokenizer_api_name)

  depends_on = [
    aws_cloudwatch_log_group.tokenizer
  ]

}

module "api_tokenizer_throttle_limit_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 3.0"

  actions_enabled     = var.env_short == "p" ? true : false
  alarm_name          = format("high-rate-limit-throttle-%s", local.tokenizer_api_name)
  alarm_description   = "Throttle rate limit too high."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 10
  period              = 60
  unit                = "Count"

  namespace   = "ErrorCount"
  metric_name = format("%s-namespace", local.tokenizer_api_name)
  statistic   = "Sum"

  alarm_actions = [aws_sns_topic.alarms.arn]

  depends_on = [
    module.log_filter_throttle_limit_tokenizer
  ]
}
