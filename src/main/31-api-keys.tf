locals {
  api_key_list = toset(var.api_keys_user_registry)
}

resource "aws_api_gateway_api_key" "main" {
  for_each = toset(local.api_key_list)
  name     = each.value
}