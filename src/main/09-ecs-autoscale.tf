# Scaling task by CPU Utilization

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count = length(local.service_ids)
  alarm_name = format("%s-CPU-Utilization-High-%s", split("/", local.service_ids[count.index])[2],
  var.ecs_as_threshold.cpu_max)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_threshold.cpu_max

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = split("/", local.service_ids[count.index])[2]
  }

  alarm_actions = [
    aws_appautoscaling_policy.app_up[count.index].arn,
    aws_sns_topic.alarms.arn,
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  count = length(local.service_ids)
  alarm_name = format("%s-CPU-Utilization-Low-%s", split("/", local.service_ids[count.index])[2],
  var.ecs_as_threshold.cpu_min)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_threshold.cpu_min

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = split("/", local.service_ids[count.index])[2]
  }

  alarm_actions = [
    aws_appautoscaling_policy.app_down[count.index].arn
  ]
}

# Scaling by memory 
resource "aws_cloudwatch_metric_alarm" "mem_utilization_high" {
  count = length(local.service_ids)
  alarm_name = format("%s-Mem-Utilization-High-%s", split("/", local.service_ids[count.index])[2],
  var.ecs_as_threshold.mem_max)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_threshold.mem_max

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = split("/", local.service_ids[count.index])[2]
  }

  alarm_actions = [
    #aws_appautoscaling_policy.app_up[count.index].arn,
    aws_sns_topic.alarms.arn,
  ]
}

/*
resource "aws_cloudwatch_metric_alarm" "mem_utilization_low" {
  count = length(local.service_ids)
  alarm_name = format("%s-Mem-Utilization-Low-%s", split("/", local.service_ids[count.index])[2],
  var.ecs_as_threshold.mem_min)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.ecs_as_threshold.mem_min

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = split("/", local.service_ids[count.index])[2]
  }

  alarm_actions = [
    aws_appautoscaling_policy.app_up[count.index].arn,
  ]
}
*/
resource "aws_appautoscaling_policy" "app_up" {
  count              = length(local.service_ids)
  name               = format("%s-scale-up", aws_ecs_cluster.ecs_cluster.name)
  service_namespace  = aws_appautoscaling_target.ecs_target[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[count.index].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "app_down" {
  count              = length(local.service_ids)
  name               = format("%s-scale-down", aws_ecs_cluster.ecs_cluster.name)
  service_namespace  = aws_appautoscaling_target.ecs_target[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[count.index].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
