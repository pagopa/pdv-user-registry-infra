resource "aws_cloudwatch_log_group" "ecs_user_registry" {
  name = format("ecs/%s", local.task_user_registry_name)

  retention_in_days = var.ecs_logs_retention_days

  tags = {
    Name = local.task_user_registry_name
  }
}

resource "aws_ecs_task_definition" "user_registry" {
  family = local.task_user_registry_name

  container_definitions = <<DEFINITION
[
  {
    "name": "${local.project}-container",
    "image": "${aws_ecr_repository.main[1].repository_url}:${var.user_registry_task.image_version}",
    "cpu": "${var.user_registry_task.container_cpu}",
    "memory": "${var.user_registry_task.container_mem}",
    "entryPoint": [],
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.ecs_user_registry.id}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${local.project}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${var.container_port_user_registry},
        "hostPort": ${var.container_port_user_registry}
      }
    ],
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "${var.aws_region}"
      },
      {
        "name": "APP_SERVER_PORT",
        "value": "${var.container_port_user_registry}"
      },
      {
        "name": "MS_TOKENIZER_URL",
        "value": "http://${var.ms_tokenizer_host_name}"
      },
      {
        "name": "MS_PERSON_URL",
        "value": "http://${module.nlb.lb_dns_name}:${var.container_port_person}"
      },
      {
        "name": "APP_LOG_LEVEL",
        "value": "${var.ms_user_registry_log_level}"
      },
      {
        "name": "REST_CLIENT_LOGGER_LEVEL",
        "value": "${var.ms_user_registry_rest_client_log_level}"
      },
      {
        "name": "ENABLE_CONFIDENTIAL_FILTER",
        "value": "${var.ms_user_registry_enable_confidential_filter}"
      },
      {
        "name": "ENABLE_SINGLE_LINE_STACK_TRACE_LOGGING",
        "value": "${var.ms_user_registry_enable_single_line_stack_trace_logging}"
      }
    ],
    "networkMode": "awsvpc"
  }
]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.user_registry_task.container_mem
  cpu                      = var.user_registry_task.container_cpu
  execution_role_arn       = aws_iam_role.ecs_execution_task.arn
  task_role_arn            = aws_iam_role.ecs_execution_task.arn

  tags = { Name = format("%s-ecs-td", local.project) }
}

data "aws_ecs_task_definition" "user_registry" {
  task_definition = aws_ecs_task_definition.user_registry.family
}

# Service
resource "aws_ecs_service" "user_registry" {
  name    = local.service_user_registry_name
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = format("%s:%s",
    aws_ecs_task_definition.user_registry.family,
    max(aws_ecs_task_definition.user_registry.revision, data.aws_ecs_task_definition.user_registry.revision)
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
      # NLB
      aws_security_group.nsg_task.id

    ]
  }

  load_balancer {
    target_group_arn = module.nlb.target_group_arns[1]
    container_name   = format("%s-container", local.project)
    container_port   = var.container_port_user_registry
  }

  depends_on = [module.nlb]

  tags = { Name : local.service_user_registry_name }
}