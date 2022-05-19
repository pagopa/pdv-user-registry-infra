module "dn_zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = var.public_dns_zones
}

resource "aws_route53_record" "uat" {
  count           = var.env_short == "p" ? 1 : 0
  allow_overwrite = true
  name            = format("uat.%s", keys(var.public_dns_zones)[0])
  ttl             = var.dns_record_ttl
  type            = "NS"
  zone_id         = module.dn_zone.route53_zone_zone_id[keys(var.public_dns_zones)[0]]

  records = [
    "ns-1095.awsdns-08.org",
    "ns-174.awsdns-21.com",
    "ns-1895.awsdns-44.co.uk",
    "ns-671.awsdns-19.net",
  ]
}

resource "aws_api_gateway_domain_name" "main" {
  count                    = var.apigw_custom_domain_create ? 1 : 0
  domain_name              = local.apigw_custom_domain
  regional_certificate_arn = aws_acm_certificate.main[0].arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "main" {
  count   = var.apigw_custom_domain_create ? 1 : 0
  zone_id = module.dn_zone.route53_zone_zone_id[keys(var.public_dns_zones)[0]]
  name    = aws_api_gateway_domain_name.main[0].domain_name
  type    = "CNAME"
  records = [aws_api_gateway_domain_name.main[0].regional_domain_name]
  ttl     = var.dns_record_ttl
}