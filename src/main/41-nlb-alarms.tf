module "nlb_unhealthy_unhealthy_targets_alarm" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-cloudwatch.git//modules/metric-alarms-by-multiple-dimensions?ref=60cf981e0f1ae033699e5b274440867e48289967"

  count = length(module.nlb.target_group_names)

  alarm_name          = "nlb-unhealthy-unhealthy-target-"
  actions_enabled     = var.env_short == "p" ? true : false
  alarm_description   = "Alarm when an unhealthy count is greater than one in the target"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  unit                = "Count"

  namespace   = "AWS/NetworkELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Sum"

  dimensions = {
    "${module.nlb.target_group_names[count.index]}" = {
      TargetGroup = module.nlb.target_group_names[count.index]
      LoadBalacer = module.nlb.lb_arn_suffix
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}