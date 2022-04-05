module "dn_zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = var.public_dns_zones
}

resource "aws_api_gateway_domain_name" "main" {
  count                    = var.apigw_custom_domain_create ? 1 : 0
  domain_name              = local.apigw_custom_domain
  regional_certificate_arn = aws_acm_certificate.main[0].arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Mapping api tokenizer with apigw custom domain.
resource "aws_api_gateway_base_path_mapping" "tokenizer" {
  count       = var.apigw_custom_domain_create ? 1 : 0
  api_id      = aws_api_gateway_rest_api.tokenizer.id
  stage_name  = local.tokenizer_stage_name
  domain_name = aws_api_gateway_domain_name.main[0].domain_name
}

resource "aws_api_gateway_base_path_mapping" "person" {
  count       = var.apigw_api_person_enable && var.apigw_custom_domain_create ? 1 : 0
  api_id      = aws_api_gateway_rest_api.person[0].id
  stage_name  = local.person_stage_name
  domain_name = aws_api_gateway_domain_name.main[0].domain_name
}

resource "aws_route53_record" "main" {
  zone_id = module.dn_zone.route53_zone_zone_id[keys(var.public_dns_zones)[0]]
  name    = aws_api_gateway_domain_name.main[0].domain_name
  type    = "CNAME"
  records = [aws_api_gateway_domain_name.main[0].regional_domain_name]
  ttl     = "60"
}