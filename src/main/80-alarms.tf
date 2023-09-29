data "aws_secretsmanager_secret" "email_operation" {
  name = "operation/alerts"
}

data "aws_secretsmanager_secret_version" "email_operation_lt" {
  secret_id = data.aws_secretsmanager_secret.email_operation.id
}

resource "aws_sns_topic" "alarms" {
  name         = format("%s-alarms", local.project)
  display_name = "Alarms"
}

resource "aws_sns_topic_subscription" "alarms_email" {
  endpoint = jsondecode(data.aws_secretsmanager_secret_version.email_operation_lt.secret_string)["email"]

  endpoint_auto_confirms = true
  protocol               = "email"
  topic_arn              = aws_sns_topic.alarms.arn
}

resource "aws_sns_topic_subscription" "alarms_opsgenie" {
  count = var.enable_opsgenie ? 1 : 0

  endpoint = jsondecode(
    data.aws_secretsmanager_secret_version.email_operation_lt.secret_string
  )["opsgenie_url"]

  endpoint_auto_confirms          = true
  protocol                        = "https"
  topic_arn                       = aws_sns_topic.alarms.arn
  confirmation_timeout_in_minutes = 15

  filter_policy = jsonencode({
    "AlarmDescription" : [{ "prefix" : local.runbook_title }]
  })

  filter_policy_scope = "MessageBody"
}