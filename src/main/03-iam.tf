data "aws_iam_policy_document" "ecs_tasks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution_task" {
  name               = format("%s-execution-task-role", local.project)
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role_policy.json
  tags               = { Name = format("%s-execution-task-role", local.project) }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecs_execution_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# policy to allow execute command.
resource "aws_iam_policy" "execute_command_policy" {
  count       = var.ecs_enable_execute_command ? 1 : 0
  name        = "PagoPaECSExecuteCommand"
  description = "Policy to allow ecs execute command."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
         "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_execute_command_policy" {
  count      = var.ecs_enable_execute_command ? 1 : 0
  role       = aws_iam_role.ecs_execution_task.name
  policy_arn = aws_iam_policy.execute_command_policy[0].arn
}


## policy to allow ecs to read and write in dynamodb
resource "aws_iam_policy" "dynamodb_rw" {
  name        = "PagoPaECSReadWriteDynamoDB"
  description = "Policy to allow ecs tasks to read and write in dynamodb table"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:GetRecords"
      ],
      "Effect": "Allow",
      "Resource": "${module.dynamodb_table.dynamodb_table_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_dynamodb_rw" {
  role       = aws_iam_role.ecs_execution_task.name
  policy_arn = aws_iam_policy.dynamodb_rw.arn
}


## IAM Groups.

resource "aws_iam_group" "developers" {
  name = "Developers"
}

data "aws_iam_policy" "power_user" {
  name = "PowerUserAccess"
}

resource "aws_iam_group_policy_attachment" "power_user" {
  count      = var.env_short == "u" ? 1 : 0
  group      = aws_iam_group.developers.name
  policy_arn = data.aws_iam_policy.power_user.arn
}