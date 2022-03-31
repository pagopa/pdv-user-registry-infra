## ecs
output "ecs_definition_task_arn" {
  value = data.aws_ecs_task_definition.main.arn
}

output "ecs_definition_task_revision" {
  value = data.aws_ecs_task_definition.main.revision
}

## dynamodb

output "dynamo_db_table_arn" {
  value = module.dynamodb_table.dynamodb_table_arn
}

output "dynamo_db_table_id" {
  value = module.dynamodb_table.dynamodb_table_id
}


# NLB
output "nlb_hostname" {
  value = module.nlb.lb_dns_name
}