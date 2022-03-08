locals {
  apigw_name = format("%s-apigw-vpc-lik", local.project)
}

/*
resource "aws_api_gateway_vpc_link" "apigw" {
  name        = local.apigw_name
  description = "allows public API Gateway for ${local.apigw_name} to talk to private NLB"
  target_arns = [module.alb.lb_arn]
}
*/