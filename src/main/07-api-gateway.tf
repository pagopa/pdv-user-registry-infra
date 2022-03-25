locals {
  apigw_name = format("%s-apigw-vpc-lik", local.project)
}

resource "aws_api_gateway_vpc_link" "apigw" {
  name        = local.apigw_name
  description = "allows public API Gateway for ${local.apigw_name} to talk to private NLB"
  target_arns = [module.nlb.lb_arn]

  tags = { Name = local.apigw_name }

}

resource "aws_api_gateway_rest_api" "main" {
  name           = format("%s-apigw", local.project)
  api_key_source = "HEADER"

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "example"
      version = "1.0"
    }
    paths = {
      "/" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = format("http://%s/", module.nlb.lb_dns_name)
            connectionType       = "VPC_LINK"
            connectionId         = aws_api_gateway_vpc_link.apigw.id
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = { Name = format("%s-apigw", local.project) }
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  #stage_name  = "prod"
}

locals {
  stage_name = "v1"
}

resource "aws_cloudwatch_log_group" "apigw" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.main.id}/${local.stage_name}"
  retention_in_days = 7
}
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = local.stage_name

  /*
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw.arn
    #todo: find a better way to represent this log format.
    format = "{ \"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
  }
  */
}

/*
resource "aws_api_gateway_method" "any" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = "ANY"
  authorization = "NONE"

  
  request_parameters = {
    "method.request.path.proxy" = true
  }
  
}
*/

resource "aws_api_gateway_usage_plan" "prod_io" {
  name        = format("%s-api-plan", local.project)
  description = "Usage plan for main api"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
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

resource "aws_api_gateway_api_key" "prod_io" {
  name = "prod-io"
}

resource "aws_api_gateway_usage_plan_key" "prod_io" {
  key_id        = aws_api_gateway_api_key.prod_io.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.prod_io.id
}

/*
//The API Gateway endpoint
output "api_gateway_endpoint" {
  value = format("https://", aws_api_gateway_domain_name.main.domain_name)
}
*/
output "invoke_url" {
  value = aws_api_gateway_deployment.main.invoke_url
}

## Firewall regional web acl  
resource "aws_wafv2_web_acl" "main" {
  name        = format("%s-webacl", local.project)
  description = "Api gateway WAF."
  scope       = "REGIONAL"

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "apiWebACL"
    sampled_requests_enabled   = true
  }
  default_action {
    allow {}
  }

  tags = { Name = format("%s-webacl", local.project) }
}

resource "aws_wafv2_web_acl_association" "main" {
  web_acl_arn  = aws_wafv2_web_acl.main.arn
  resource_arn = "arn:aws:apigateway:${var.aws_region}::/restapis/${aws_api_gateway_rest_api.main.id}/stages/${aws_api_gateway_stage.main.stage_name}"
}

## API Gateway cloud watch logs
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.apigw.arn
}

resource "aws_iam_role" "apigw" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.apigw.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}