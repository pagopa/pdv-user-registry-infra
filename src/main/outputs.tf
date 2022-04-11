## ecs
output "ecs_definition_task_arn" {
  value = data.aws_ecs_task_definition.tokenizer.arn
}

output "ecs_definition_task_revision" {
  value = data.aws_ecs_task_definition.tokenizer.revision
}

output "ecs_task_definition_tokenizer_arn" {
  value = data.aws_ecs_task_definition.tokenizer.arn
}

output "ecs_task_definition_tokenizer_revision" {
  value = data.aws_ecs_task_definition.tokenizer.revision
}

output "ecs_task_definition_person_arn" {
  value = data.aws_ecs_task_definition.person.arn
}

output "ecs_task_definition_person_revision" {
  value = data.aws_ecs_task_definition.person.revision
}

## dynamodb

output "dynamodb_table_token_arn" {
  value = module.dynamodb_table_token.dynamodb_table_arn
}
output "dynamodb_table_token_id" {
  value = module.dynamodb_table_token.dynamodb_table_id
}

output "dynamodb_table_person_arn" {
  value = module.dynamodb_table_person.dynamodb_table_arn
}
output "dynamodb_table_person_id" {
  value = module.dynamodb_table_person.dynamodb_table_id
}

# Dns
output "public_dns_zone_name" {
  value = module.dn_zone.route53_zone_name
}

output "public_dns_servers" {
  value = module.dn_zone.route53_zone_name_servers
}

# NLB
output "nlb_hostname" {
  value = module.nlb.lb_dns_name
}

# API Gateway

output "api_gateway_endpoint" {
  value = var.apigw_custom_domain_create ? format("https://%s", aws_api_gateway_domain_name.main[0].domain_name) : ""
}