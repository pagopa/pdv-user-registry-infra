locals {
  task_poc_name    = format("%s-task-poc", local.project)
  service_poc_name = format("%s-service-poc", local.project)
}

resource "aws_cloudwatch_log_group" "ecs_poc" {
  name = format("ecs/%s", local.task_poc_name)

  retention_in_days = var.ecs_logs_retention_days

  tags = {
    Name = local.task_poc_name
  }
}

resource "aws_ecs_task_definition" "poc" {
  family = local.task_poc_name

  container_definitions = <<DEFINITION
[
  {
    "name": "${local.project}-container",
    "image": "${aws_ecr_repository.main[3].repository_url}:latest",
    "entryPoint": [],
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.ecs_poc.id}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${local.project}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${var.container_port_poc},
        "hostPort": ${var.container_port_poc}
      }
    ],
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "${var.aws_region}"
      },
      {
        "name": "MS_poc_SERVER_PORT",
        "value": "${var.container_port_poc}"
      },
      {
        "name": "MS_TOKENIZER_URL",
        "value": "http://${module.nlb.lb_dns_name}"
      },
      {
        "name": "MS_PERSON_URL",
        "value": "http://${module.nlb.lb_dns_name}:${var.container_port_person}"
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

data "aws_ecs_task_definition" "poc" {
  task_definition = aws_ecs_task_definition.poc.family
}

# Service
resource "aws_ecs_service" "poc" {
  name    = local.service_poc_name
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = format("%s:%s",
    aws_ecs_task_definition.poc.family,
    max(aws_ecs_task_definition.poc.revision, data.aws_ecs_task_definition.poc.revision)
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
    target_group_arn = module.nlb.target_group_arns[2]
    container_name   = format("%s-container", local.project)
    container_port   = var.container_port_poc
  }

  depends_on = [module.nlb]

  tags = { Name : local.service_poc_name }
}