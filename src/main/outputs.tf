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

output "dynamodb_table_token_eu_south_1_arn" {
  value = module.dynamodb_table_token_eu_south_1.dynamodb_table_arn
}
output "dynamodb_table_token_eu_south_1_id" {
  value = module.dynamodb_table_token_eu_south_1.dynamodb_table_id
}

## replica 
output "dynamodb_table_token_eu_central_1_arn" {
  value = try(module.dynamodb_table_token_eu_central_1[0].dynamodb_table_arn, null)
}
output "dynamodb_table_token_eu_central_1_id" {
  value = try(module.dynamodb_table_token_eu_central_1[0].dynamodb_table_id, null)
}

## Table person
output "dynamodb_table_person_eu_south_1_arn" {
  value = module.dynamodb_table_person_eu_south_1.dynamodb_table_arn
}
output "dynamodb_table_person_eu_south_1_id" {
  value = module.dynamodb_table_person_eu_south_1.dynamodb_table_id
}

# replica 
output "dynamodb_table_person_eu_central_1_arn" {
  value = try(module.dynamodb_table_person_eu_central_1[0].dynamodb_table_arn, null)
}
output "dynamodb_table_person_eu_central_1_id" {
  value = try(module.dynamodb_table_person_eu_central_1[0].dynamodb_table_id, null)
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