locals {
  task_tokenizer_name    = format("%s-task-tokenizer", local.project)
  service_tokenizer_name = format("%s-service-tokenizer", local.project)
}

resource "aws_cloudwatch_log_group" "ecs_tokenizer" {
  name = format("ecs/%s", local.task_tokenizer_name)

  retention_in_days = var.ecs_logs_retention_days

  tags = {
    Name = local.task_tokenizer_name
  }
}

resource "aws_ecs_task_definition" "tokenizer" {
  family = local.task_tokenizer_name

  container_definitions = <<DEFINITION
[
  {
    "name": "${local.project}-container",
    "image": "${aws_ecr_repository.main[0].repository_url}:latest",
    "entryPoint": [],
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.ecs_tokenizer.id}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${local.project}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${var.container_port_tokenizer},
        "hostPort": ${var.container_port_tokenizer}
      }
    ],
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "${var.aws_region}"
      }
    ],
    "cpu": 256,
    "memory": 512,
    "networkMode": "awsvpc"
  }
]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_execution_task.arn
  task_role_arn            = aws_iam_role.ecs_execution_task.arn

  tags = { Name = format("%s-ecs-td", local.project) }
}

data "aws_ecs_task_definition" "tokenizer" {
  task_definition = aws_ecs_task_definition.tokenizer.family
}

# Service
resource "aws_ecs_service" "tokenizer" {
  name    = local.service_tokenizer_name
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = format("%s:%s",
    aws_ecs_task_definition.tokenizer.family,
    max(aws_ecs_task_definition.tokenizer.revision, data.aws_ecs_task_definition.tokenizer.revision)
  )
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  desired_count          = var.replica_count
  force_new_deployment   = true
  enable_execute_command = var.ecs_enable_execute_command

  network_configuration {
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
    security_groups = [
      # ALB
      #aws_security_group.service_security_group.id,
      #aws_security_group.alb.id,
      # NLB
      aws_security_group.nsg_task.id

    ]
  }

  load_balancer {
    target_group_arn = module.nlb.target_group_arns[0]
    container_name   = format("%s-container", local.project)
    container_port   = var.container_port_tokenizer
  }

  depends_on = [module.nlb]

  tags = { Name : local.service_tokenizer_name }
}

