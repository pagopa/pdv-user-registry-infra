locals {
  user_registry_api_name         = format("%s-user-registry-api", local.project)
  user_registry_stage_name       = "v1"
  list_user_registry_key_to_name = [for n in var.api_keys_user_registry : "'${aws_api_gateway_api_key.main[n].id}':'${aws_api_gateway_api_key.main[n].name}'"]
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
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.user_registry.id}/${local.user_registry_stage_name}"
  retention_in_days = 7

  tags = { Name = local.user_registry_api_name }

}
resource "aws_api_gateway_stage" "user_registry" {
  deployment_id      = aws_api_gateway_deployment.user_registry.id
  rest_api_id        = aws_api_gateway_rest_api.user_registry.id
  stage_name         = local.user_registry_stage_name
  cache_cluster_size = 0.5 #why is this needed ?

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
    data_trace_enabled = true
    logging_level      = "ERROR"
    #todo.
    # Limit the rate of calls to prevent abuse and unwanted charges
    #throttling_rate_limit  = 100
    #throttling_burst_limit = 50
  }
}

resource "aws_api_gateway_usage_plan" "user_registry" {
  name        = format("%s-api-user_registry", local.project)
  description = "Usage plan for main user_registry apis"

  api_stages {
    api_id = aws_api_gateway_rest_api.user_registry.id
    stage  = aws_api_gateway_stage.user_registry.stage_name

    dynamic "throttle" {
      for_each = var.api_user_registry_throttling.method_throttle
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
    burst_limit = var.api_user_registry_throttling.burst_limit
    rate_limit  = var.api_user_registry_throttling.rate_limit
  }
}

resource "aws_api_gateway_usage_plan_key" "user_registry" {
  for_each      = toset(var.api_keys_user_registry)
  key_id        = aws_api_gateway_api_key.main[each.value].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.user_registry.id
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
  value     = { for k in var.api_keys_user_registry : k => aws_api_gateway_usage_plan_key.user_registry[k].value }
  sensitive = true
}

output "user_registry_api_ids" {
  value = { for k in var.api_keys_user_registry : k => aws_api_gateway_usage_plan_key.user_registry[k].id }
}

output "user_registryinvoke_url" {
  value = try(aws_api_gateway_deployment.user_registry.invoke_url, null)
}