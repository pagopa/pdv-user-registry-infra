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
  name = format("%s-apigw", local.project)

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
            responses = {
              "200" = {
                statusCode = "200"
                responseTemplates = {
                  "application/json" = "#set ($root=$input.path('$')) { \"stage\": \"$root.name\", \"user-id\": \"$root.key\" }"
                  "application/xml"  = "#set ($root=$input.path('$')) <stage>$root.name</stage> "
                }
              }
              "302" = {
                statusCode = "302"
                responseParameters = {
                  "method.response.header.Location" = "integration.response.body.redirect.url"
                }
              }
            }
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
  stage_name  = "v1"
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
