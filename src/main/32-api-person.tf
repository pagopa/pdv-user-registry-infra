locals {
  person_api_name   = format("%s-person-api", local.project)
  person_stage_name = "v1"
}

resource "aws_api_gateway_rest_api" "person" {
  count          = var.apigw_api_person_enable ? 1 : 0
  name           = local.person_api_name
  api_key_source = "HEADER"

  body = templatefile("./api/ms_person/api-docs.tpl.json",
    {
      uri           = format("http://%s:%s", module.nlb.lb_dns_name, var.container_port_person),
      connection_id = aws_api_gateway_vpc_link.apigw.id
    }
  )

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = { Name = local.person_api_name }
}

resource "aws_api_gateway_deployment" "person" {
  count       = var.apigw_api_person_enable ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.person[0].id
  # stage_name  = local.person_stage_name

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.person[0].body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "person" {
  count             = var.apigw_api_person_enable ? 1 : 0
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.person[0].id}/${local.person_stage_name}"
  retention_in_days = var.apigw_execution_logs_retention

  tags = { Name = local.person_api_name }
}
resource "aws_api_gateway_stage" "person" {
  count              = var.apigw_api_person_enable ? 1 : 0
  deployment_id      = aws_api_gateway_deployment.person[0].id
  rest_api_id        = aws_api_gateway_rest_api.person[0].id
  stage_name         = local.person_stage_name
  cache_cluster_size = 0.5 #why is this needed ?

  dynamic "access_log_settings" {
    for_each = var.apigw_access_logs_enable ? ["dymmy"] : []
    content {
      destination_arn = aws_cloudwatch_log_group.person[0].arn
      #todo: find a better way to represent this log format.
      format = "{ \"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
    }
  }
}

resource "aws_api_gateway_method_settings" "person" {
  count       = var.apigw_api_person_enable ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.person[0].id
  stage_name  = local.person_stage_name
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

resource "aws_api_gateway_usage_plan" "person" {
  count       = var.apigw_api_person_enable ? 1 : 0
  name        = format("%s-api-person", local.project)
  description = "Usage plan for main person apis"

  api_stages {
    api_id = aws_api_gateway_rest_api.person[0].id
    stage  = aws_api_gateway_stage.person[0].stage_name
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
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_api_key" "person" {
  count = var.apigw_api_person_enable ? 1 : 0
  name  = "person"
}

resource "aws_api_gateway_usage_plan_key" "person" {
  count         = var.apigw_api_person_enable ? 1 : 0
  key_id        = aws_api_gateway_api_key.person[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.person[0].id
}

resource "aws_api_gateway_base_path_mapping" "person" {
  count       = var.apigw_api_person_enable && var.apigw_custom_domain_create ? 1 : 0
  api_id      = aws_api_gateway_rest_api.person[0].id
  stage_name  = local.person_stage_name
  domain_name = aws_api_gateway_domain_name.main[0].domain_name
  base_path   = "person"
}

## WAF association
resource "aws_wafv2_web_acl_association" "person" {
  count        = var.apigw_api_person_enable ? 1 : 0
  web_acl_arn  = aws_wafv2_web_acl.main.arn
  resource_arn = "arn:aws:apigateway:${var.aws_region}::/restapis/${aws_api_gateway_rest_api.person[0].id}/stages/${aws_api_gateway_stage.person[0].stage_name}"
}

output "person_api_key" {
  value     = try(aws_api_gateway_usage_plan_key.person[0].value, null)
  sensitive = true
}

/*
//The API Gateway endpoint
output "api_gateway_endpoint" {
  value = format("https://", aws_api_gateway_domain_name.main.domain_name)
}
*/
output "personinvoke_url" {
  value = try(aws_api_gateway_deployment.person[0].invoke_url, null)
}