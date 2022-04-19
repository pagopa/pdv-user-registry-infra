resource "aws_api_gateway_api_key" "tokenizer" {
  for_each = toset(var.api_keys_tokenizer)
  name     = each.value
}

resource "aws_api_gateway_api_key" "user_registry" {
  for_each = toset(var.api_keys_user_registry)
  name     = each.value
}