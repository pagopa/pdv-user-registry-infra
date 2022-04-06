data "aws_secretsmanager_secret" "io_operation" {
  name = "operation/alerts"
}

data "aws_secretsmanager_secret_version" "io_operation_lt" {
  secret_id = data.aws_secretsmanager_secret.io_operation.id
}

resource "aws_sns_topic" "alarms" {
  name         = format("%s-alarms", local.project)
  display_name = "Alarms"
}

resource "aws_sns_topic_subscription" "alarms_email" {
  endpoint = jsondecode(data.aws_secretsmanager_secret_version.io_operation_lt.secret_string)["email"]

  endpoint_auto_confirms = true
  protocol               = "email"
  topic_arn              = aws_sns_topic.alarms.arn
}