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
  tags               = var.tags
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