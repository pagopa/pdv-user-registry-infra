locals {
  apigw_name = format("%s-apigw-vpc-lik", local.project)
}

resource "aws_api_gateway_vpc_link" "apigw" {
  name        = local.apigw_name
  description = "allows public API Gateway for ${local.apigw_name} to talk to private NLB"
  target_arns = [module.nlb.lb_arn]

  tags = var.tags

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

  tags = var.tags
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
