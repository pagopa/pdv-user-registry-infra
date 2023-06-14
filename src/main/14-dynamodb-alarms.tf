# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html

module "dynamodb_metric_alarms" {
  count   = length(var.dynamodb_alarms)
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.3.0"

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
  version = "4.3.0"

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

## Read capacity units
module "dynamodb_read_capacity_units_limit_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "4.3.0"

  alarm_name          = "dynamodb-read-capacity-units-"
  actions_enabled     = var.env_short == "p" ? true : false
  alarm_description   = "Alarm when read capacity reaches 80% of provisioned read capacity"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.table_person_read_capacity - (var.table_person_read_capacity * 0.2)
  period              = 60

  namespace   = "AWS/DynamoDB"
  metric_name = "ConsumedReadCapacityUnits"
  statistic   = "Average"

  dimensions = {
    "person" = {
      TableName = local.dynamodb_table_person
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

## Write capacity units
module "dynamodb_write_capacity_units_limit_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "4.3.0"

  alarm_name          = "dynamodb-write-capacity-units-"
  actions_enabled     = var.env_short == "p" ? true : false
  alarm_description   = "Alarm when write capacity reaches 80% of provisioned read capacity"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.table_person_write_capacity - (var.table_person_write_capacity * 0.2)
  period              = 60

  namespace   = "AWS/DynamoDB"
  metric_name = "ConsumedWriteCapacityUnits"
  statistic   = "Average"

  dimensions = {
    "person" = {
      TableName = local.dynamodb_table_person
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

### Global secondary index read capacity.
module "gsi_index_read_capacity_units_limit_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "4.3.0"

  alarm_name          = "read-capacity-units-"
  actions_enabled     = var.env_short == "p" ? true : false
  alarm_description   = "Alarm when read capacity reaches 80% of provisioned read capacity"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["read_max_capacity"] - (var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["read_max_capacity"] * 0.2)
  period              = 60

  namespace   = "AWS/DynamoDB"
  metric_name = "ConsumedReadCapacityUnits"
  statistic   = "Average"

  dimensions = {
    "gsi_index" = {
      GlobalSecondaryIndexName = local.dynamodb_gsi_person_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

### Global secondary write read capacity.
module "gsi_index_write_capacity_units_limit_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "4.3.0"

  alarm_name          = "write-capacity-units-"
  actions_enabled     = var.env_short == "p" ? true : false
  alarm_description   = "Alarm when read capacity reaches 80% of provisioned read capacity"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["write_max_capacity"] - (var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["write_max_capacity"] * 0.2)
  period              = 60

  namespace   = "AWS/DynamoDB"
  metric_name = "ConsumedWriteCapacityUnits"
  statistic   = "Average"

  dimensions = {
    "gsi_index" = {
      GlobalSecondaryIndexName = local.dynamodb_gsi_person_name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}

#ExceedingThroughput
module "dynamodb_request_exceeding_throughput_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "4.3.0"

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