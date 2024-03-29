resource "aws_cloudwatch_log_group" "ecs_person" {
  name = format("ecs/%s", local.task_person_name)

  retention_in_days = var.ecs_logs_retention_days

  tags = {
    Name = local.task_person_name
  }
}

resource "aws_ecs_task_definition" "person" {
  family = local.task_person_name

  container_definitions = <<DEFINITION
[
  {
    "name": "${local.project}-container",
    "image": "${aws_ecr_repository.main[0].repository_url}:${var.person_task.image_version}",
    "cpu": ${var.person_task.container_cpu - var.x_ray_daemon_container_cpu},
    "memory": ${var.person_task.container_mem - var.x_ray_daemon_container_memory},
    "entryPoint": [],
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.ecs_person.id}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${local.project}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${var.container_port_person},
        "hostPort": ${var.container_port_person}
      }
    ],
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "${var.aws_region}"
      },
      {
        "name": "APP_SERVER_PORT",
        "value": "${var.container_port_person}"
      },
      {
        "name": "APP_LOG_LEVEL",
        "value": "${var.ms_person_log_level}"
      },
      {
        "name": "REST_CLIENT_LOGGER_LEVEL",
        "value": "${var.ms_person_rest_client_log_level}"
      },
      {
        "name": "ENABLE_CONFIDENTIAL_FILTER",
        "value": "${var.ms_person_enable_confidential_filter}"
      },
      {
        "name": "ENABLE_SINGLE_LINE_STACK_TRACE_LOGGING",
        "value": "${var.ms_person_enable_single_line_stack_trace_logging}"
      }
    ]
  },
  {
    "name": "${local.project}-xray-daemon-container",
    "image": "${aws_ecr_repository.main[2].repository_url}:${var.x_ray_daemon_image_version}",
    "command": ["--log-level", "error"],
    "cpu": ${var.x_ray_daemon_container_cpu},
    "memoryReservation": ${var.x_ray_daemon_container_memory},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.ecs_person.id}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${local.project}"
      }
    },
    "portMappings" : [
        {
            "containerPort": 2000,
            "protocol": "udp"
        }
    ]
  }
]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.person_task.mem
  cpu                      = var.person_task.cpu
  execution_role_arn       = aws_iam_role.ecs_execution_task.arn
  task_role_arn            = aws_iam_role.ecs_execution_task.arn

  tags = { Name = format("%s-ecs-td", local.project) }
}

data "aws_ecs_task_definition" "person" {
  task_definition = aws_ecs_task_definition.person.family
}

# Service
resource "aws_ecs_service" "person" {
  name    = local.service_person_name
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = format("%s:%s",
    aws_ecs_task_definition.person.family,
    max(aws_ecs_task_definition.person.revision, data.aws_ecs_task_definition.person.revision)
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
    target_group_arn = module.nlb.target_group_arns[0]
    container_name   = format("%s-container", local.project)
    container_port   = var.container_port_person
  }

  depends_on = [module.nlb]

  tags = { Name : local.service_person_name }
}