locals {
  api_key_list = toset(concat(var.api_keys_tokenizer, var.api_keys_user_registry))
}

resource "aws_api_gateway_api_key" "main" {
  for_each = toset(local.api_key_list)
  name     = each.value
}