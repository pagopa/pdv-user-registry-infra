locals {
  apigw_custom_domain = join(".", ["api", keys(var.public_dns_zones)[0]])
}

resource "aws_acm_certificate" "main" {
  count             = var.apigw_custom_domain_create ? 1 : 0
  domain_name       = local.apigw_custom_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = var.apigw_custom_domain_create ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 3600 # 1 hour
  type            = each.value.type
  zone_id         = module.dn_zone.route53_zone_zone_id[keys(var.public_dns_zones)[0]]
}

