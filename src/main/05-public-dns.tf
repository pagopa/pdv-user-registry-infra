module "dn_zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = var.public_dns_zones
}

resource "aws_api_gateway_domain_name" "main" {
  domain_name              = join(".", ["api", keys(var.public_dns_zones)[0]])
  regional_certificate_arn = aws_acm_certificate.main.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "main" {
  zone_id = module.dn_zone.route53_zone_zone_id[keys(var.public_dns_zones)[0]]
  name    = aws_api_gateway_domain_name.main.domain_name
  type    = "CNAME"
  records = [aws_api_gateway_domain_name.main.regional_domain_name]
  ttl     = "60"
}