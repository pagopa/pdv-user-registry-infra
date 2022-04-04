## ecs
output "ecs_definition_task_arn" {
  value = data.aws_ecs_task_definition.tokenizer.arn
}

output "ecs_definition_task_revision" {
  value = data.aws_ecs_task_definition.tokenizer.revision
}

## dynamodb

output "dynamodb_table_token_arn" {
  value = module.dynamodb_table_token.dynamodb_table_arn
}
output "dynamodb_table_token_id" {
  value = module.dynamodb_table_token.dynamodb_table_id
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
