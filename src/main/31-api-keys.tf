locals {
  api_key_list = { for k in var.user_registry_plans : k.key_name => k }
}

resource "aws_api_gateway_api_key" "main" {
  for_each = local.api_key_list
  name     = each.key
}