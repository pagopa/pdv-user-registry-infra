module "nlb_unhealthy_unhealthy_targets_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "~> 3.0"

  count = length(module.nlb.target_group_names)

  alarm_name          = "nlb-unhealthy-unhealthy-target-"
  actions_enabled     = var.env_short == "p" ? true : false
  alarm_description   = "Alarm when an unhealthy count is greater than one in the target"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  unit                = "Count"

  namespace   = "AWS/NetworkELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Sum"

  dimensions = {
    "target" = {
      TargetGroup = module.nlb.target_group_names[count.index]
      LoadBalacer = module.nlb.lb_arn_suffix
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}