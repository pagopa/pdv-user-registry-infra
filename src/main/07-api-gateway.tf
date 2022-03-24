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

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "v1"
}


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
