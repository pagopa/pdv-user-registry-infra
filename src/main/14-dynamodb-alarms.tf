# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html

module "metric_alarms" {
  count   = length(var.dynamodb_alarms)
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 3.0"

  actions_enabled     = var.dynamodb_alarms[count.index].actions_enabled
  alarm_name          = var.dynamodb_alarms[count.index].alarm_name
  alarm_description   = var.dynamodb_alarms[count.index].alarm_description
  comparison_operator = var.dynamodb_alarms[count.index].comparison_operator
  evaluation_periods  = var.dynamodb_alarms[count.index].evaluation_periods
  threshold           = var.dynamodb_alarms[count.index].threshold
  period              = var.dynamodb_alarms[count.index].period
  unit                = var.dynamodb_alarms[count.index].unit
  datapoints_to_alarm = var.dynamodb_alarms[count.index].datapoints_to_alarm

  namespace   = var.dynamodb_alarms[count.index].namespace
  metric_name = var.dynamodb_alarms[count.index].metric_name
  statistic   = var.dynamodb_alarms[count.index].statistic

  alarm_actions = [aws_sns_topic.alarms.arn]
}

module "dynamo_successful_request_latency" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 3.0"

  alarm_name          = "dynamodb-successful-request-latency"
  alarm_description   = "Dynamodb successful request latency"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 2
  threshold_metric_id = "ad1"

  metric_query = [
    {
      id          = "m1"
      return_data = true

      metric = [{
        dimensions  = null
        metric_name = "SuccessfulRequestLatency"
        namespace   = "AWS/DynamoDB"
        period      = 300
        stat        = "Maximum"
        unit        = "Percent"
        },
      ]
      }, {
      expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
      id          = "ad1"
      label       = "SuccessfulRequestLatency"
      return_data = true
    },
  ]
}

