locals {
  plan_details_api_name       = format("%s-plan-details-api", local.project)
  plan_details_stage_name     = "private-v1"
  plan_details_log_group_name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.plan_details.id}/${local.plan_details_stage_name}"
}

## Role that allows api gateway to invoke lambda functions.
data "aws_iam_policy_document" "apigw_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_apigw_proxy" {
  name               = "${local.plan_details_api_name}-lambda-proxy"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume_role.json
}

data "aws_iam_policy_document" "lambda_apigw_proxy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_apigw_proxy" {
  name        = "apigw-invoke-lambda"
  description = "Lambda invoke policy"
  policy      = data.aws_iam_policy_document.lambda_apigw_proxy.json
}

resource "aws_iam_role_policy_attachment" "lambda_apigw_proxy" {
  role       = aws_iam_role.lambda_apigw_proxy.name
  policy_arn = aws_iam_policy.lambda_apigw_proxy.arn
}

resource "aws_api_gateway_rest_api" "plan_details" {
  name           = local.plan_details_api_name
  api_key_source = "HEADER"

  body = templatefile("./api/ms_user_registry/api-expose-usage-plan-details.tpl.json",
    {
      uri                           = format("http://%s:%s", module.nlb.lb_dns_name, var.container_port_user_registry),
      connection_id                 = aws_api_gateway_vpc_link.apigw.id
      lambda_usage_plan_details_arn = module.lambda_usage_plan_details.lambda_function_arn
      lambda_apigateway_proxy_role  = aws_iam_role.lambda_apigw_proxy.arn
      aws_region                    = var.aws_region
    }
  )

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [var.oi_integration_vpc_endpoint_id]
  }

  disable_execute_api_endpoint = false

  tags = { Name = local.plan_details_api_name }
}

data "aws_iam_policy_document" "plan_details_policy" {
  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.plan_details.execution_arn}/*"]

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
    resources = ["${aws_api_gateway_rest_api.plan_details.execution_arn}/*"]

  }
}
resource "aws_api_gateway_rest_api_policy" "plan_details_policy" {
  rest_api_id = aws_api_gateway_rest_api.plan_details.id
  policy      = data.aws_iam_policy_document.plan_details_policy.json
}

resource "aws_api_gateway_deployment" "plan_details" {
  rest_api_id = aws_api_gateway_rest_api.plan_details.id
  # stage_name  = local.plan_details_stage_name

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.plan_details.*))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_rest_api_policy.plan_details_policy]

}

resource "aws_cloudwatch_log_group" "plan_details" {
  name              = local.plan_details_log_group_name
  retention_in_days = var.apigw_execution_logs_retention

  tags = { Name = local.plan_details_api_name }

}
resource "aws_api_gateway_stage" "plan_details" {
  deployment_id      = aws_api_gateway_deployment.plan_details.id
  rest_api_id        = aws_api_gateway_rest_api.plan_details.id
  stage_name         = local.plan_details_stage_name
  cache_cluster_size = 0.5 #why is this needed ?
  # documentation_version = aws_api_gateway_documentation_version.main.version
  xray_tracing_enabled = true

  dynamic "access_log_settings" {
    for_each = var.apigw_access_logs_enable ? ["dymmy"] : []
    content {
      destination_arn = aws_cloudwatch_log_group.plan_details.arn
      #todo: find a better way to represent this log format.
      format = "{ \"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
    }
  }
}

resource "aws_api_gateway_method_settings" "plan_details" {
  rest_api_id = aws_api_gateway_rest_api.plan_details.id
  stage_name  = local.plan_details_stage_name
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

  depends_on = [aws_api_gateway_stage.plan_details]

}

resource "aws_api_gateway_usage_plan" "plan_details" {
  for_each    = local.plan_details_api_key_list
  name        = format("%s-api-plan-%s", local.plan_details_api_name, lower(each.key))
  description = "Usage plan for plan_details apis"

  api_stages {
    api_id = aws_api_gateway_rest_api.plan_details.id
    stage  = aws_api_gateway_stage.plan_details.stage_name

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

  depends_on = [aws_api_gateway_stage.plan_details]

}

resource "aws_api_gateway_usage_plan_key" "plan_details" {
  for_each      = local.plan_details_api_key_list
  key_id        = aws_api_gateway_api_key.plan_details[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.plan_details[each.key].id
}


## WAF association
resource "aws_wafv2_web_acl_association" "plan_details" {
  web_acl_arn  = aws_wafv2_web_acl.main.arn
  resource_arn = "arn:aws:apigateway:${var.aws_region}::/restapis/${aws_api_gateway_rest_api.plan_details.id}/stages/${aws_api_gateway_stage.plan_details.stage_name}"
}

output "plan_details_api_keys" {
  value     = { for k in keys(local.plan_details_api_key_list) : k => aws_api_gateway_usage_plan_key.plan_details[k].value }
  sensitive = true
}

output "plan_details_invoke_url" {
  value = try(aws_api_gateway_deployment.plan_details.invoke_url, null)
}
