resource "aws_ecs_cluster" "ecs_cluster" {
  name = format("%s-ecs-cluster", local.project)
  tags = { Name = format("%s-ecs", local.project) }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = format("%s-ecs-logs", local.project)

  retention_in_days = var.ecs_logs_retention_days

  tags = {
    Application = var.app_name
  }
}

## Task definitions
/*
data "template_file" "env_vars" {
  template = file("env_vars.json")
}
*/

resource "aws_ecs_task_definition" "aws_ecs_task" {
  family = format("%s-task", local.project)

  container_definitions = <<DEFINITION
[
  {
    "name": "${local.project}-container",
    "image": "${aws_ecr_repository.ecr.repository_url}:latest",
    "entryPoint": [],
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.ecs_log_group.id}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${local.project}"
      }
    },
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ],
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "${var.aws_region}"
      },
      {
        "name": "DYNAMODB_TABLE",
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

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws_ecs_task.family
}

# services

resource "aws_ecs_service" "ecs_service" {
  name    = format("%s-ecs-service", local.project)
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = format("%s:%s",
    aws_ecs_task_definition.aws_ecs_task.family,
    max(aws_ecs_task_definition.aws_ecs_task.revision, data.aws_ecs_task_definition.main.revision)
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
    container_port   = var.container_port
  }

  depends_on = [module.nlb]

  tags = { Name : format("%s-ecs-service", local.project) }
}


## Autoscaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = join("/", ["service", aws_ecs_cluster.ecs_cluster.name, aws_ecs_service.ecs_service.name])
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = format("%s-memory-autoscaling", local.project)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = format("%s-cpu-autoscaling", local.project)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }
}