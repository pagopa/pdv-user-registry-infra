# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html

module "dynamodb_metric_alarms" {
  count  = length(var.dynamodb_alarms)
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-cloudwatch.git//modules/metric-alarm?ref=60cf981e0f1ae033699e5b274440867e48289967"

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
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-cloudwatch.git//modules/metric-alarm?ref=60cf981e0f1ae033699e5b274440867e48289967"

  alarm_name          = "dynamodb-successful-request-latency"
  actions_enabled     = var.env_short == "p" ? true : false
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

  alarm_actions = [aws_sns_topic.alarms.arn]
}


#ExceedingThroughput
module "dynamodb_request_exceeding_throughput_alarm" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-cloudwatch.git//modules/metric-alarms-by-multiple-dimensions?ref=60cf981e0f1ae033699e5b274440867e48289967"

  alarm_name          = "dynamodb-exceeding-throughput-"
  actions_enabled     = var.env_short == "p" ? true : false
  alarm_description   = "Alarm when my requests are exceeding provisioned throughput quotas of a table."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 300
  unit                = "Count"

  namespace   = "AWS/DynamoDB"
  metric_name = "ThrottledRequests"
  statistic   = "Sum"

  dimensions = {
    "person-getitem" = {
      TableName = local.dynamodb_table_person
      Operation = "GetItem"
    },
    "person-query" = {
      TableName = local.dynamodb_table_person
      Operation = "Query"
    },
    "person-putitem" = {
      TableName = local.dynamodb_table_person
      Operation = "PutItem"
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}