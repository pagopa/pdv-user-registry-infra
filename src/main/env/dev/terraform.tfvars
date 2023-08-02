env_short   = "d"
environment = "dev"

# Network
enable_nat_gateway = false

## Vpc peering
vpc_peering = null
/*
vpc_peering = {
  peer_vpc_id         = "todo"
  peer_owner_id       = "todo"
  peer_profile        = "ppa-tokenizer-data-vault-dev"
  accepter_cidr_block = "10.1.0.0/16"
}
*/
# Ecs
ecs_enable_execute_command = true
# Ecs
replica_count = 1

ecs_autoscaling = {
  max_capacity       = 3
  min_capacity       = 1
  scale_in_cooldown  = 900 # 15mins
  scale_out_cooldown = 60  # 1 min
}

person_task = {
  image_version = "todo"
  cpu           = 256
  mem           = 512
  container_cpu = 256
  container_mem = 512
}

user_registry_task = {
  image_version = "todo"
  cpu           = 1024
  mem           = 2048
  container_cpu = 1024
  container_mem = 2048
}

ms_tokenizer_host_name = "dev"

public_dns_zones = {
  "dev.pdv.pagopa.it" = {
    comment = "Personal data vault (Uat)"

  }
}


# App
ms_person_enable_single_line_stack_trace_logging        = true
ms_user_registry_enable_single_line_stack_trace_logging = true


# Api gateway
apigw_custom_domain_create = true
apigw_access_logs_enable   = false

user_registry_plans = [
  {
    key_name        = "SANDBOX"
    burst_limit     = 20
    rate_limit      = 10
    additional_keys = []
    method_throttle = []
  },
]


# dynamodb
dynamodb_point_in_time_recovery_enabled = false

## table Person
table_person_read_capacity  = 10
table_person_write_capacity = 10

table_person_autoscaling_read = {
  scale_in_cooldown  = 10
  scale_out_cooldown = 10
  target_value       = 70
  max_capacity       = 100
}

table_person_autoscaling_write = {
  scale_in_cooldown  = 10
  scale_out_cooldown = 10
  target_value       = 50
  max_capacity       = 100
}

table_person_autoscling_indexes = {
  gsi_namespaced_id = {
    read_max_capacity  = 50
    read_min_capacity  = 10
    write_max_capacity = 50
    write_min_capacity = 10
  }
}

## alarms
dynamodb_alarms = [{
  actions_enabled     = true
  alarm_name          = "dynamodb-account-provisioned-read-capacity"
  alarm_description   = "Account provisioned read capacity greater than 80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = null
  threshold           = 80

  period = 300
  unit   = "Percent"

  namespace   = "AWS/DynamoDB"
  metric_name = "AccountProvisionedReadCapacityUtilization"
  statistic   = "Maximum"

  },
  {
    actions_enabled     = true
    alarm_name          = "dynamodb-account-provisioned-write-capacity"
    alarm_description   = "Account provisioned write capacity greater than 80%"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    datapoints_to_alarm = null
    threshold           = 80
    period              = 300
    unit                = "Percent"
    namespace           = "AWS/DynamoDB"
    metric_name         = "AccountProvisionedWriteCapacityUtilization"
    statistic           = "Maximum"
  },
  {
    actions_enabled     = true
    alarm_name          = "dynamodb-max-provisioned-table-read-capacity-utilization"
    alarm_description   = "Account provisioned write capacity greater than 80%"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    datapoints_to_alarm = null
    threshold           = 80
    period              = 300
    unit                = "Percent"

    namespace   = "AWS/DynamoDB"
    metric_name = "MaxProvisionedTableReadCapacityUtilization"
    statistic   = "Maximum"
  },
  {
    actions_enabled     = true
    alarm_name          = "dynamodb-max-provisioned-table-write-capacity-utilization"
    alarm_description   = "Account provisioned write capacity greater than 80%"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    datapoints_to_alarm = null
    threshold           = 80
    period              = 300
    unit                = "Percent"

    namespace   = "AWS/DynamoDB"
    metric_name = "MaxProvisionedTableWriteCapacityUtilization"
    statistic   = "Maximum"
  },
  {
    actions_enabled     = true
    alarm_name          = "dynamodb-consumed-read-capacity-units"
    alarm_description   = "Consumed Read Capacity Units"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    datapoints_to_alarm = null
    threshold           = 10 #TODO this threashold should be equal to the Read Capacy Unit.
    period              = 300
    unit                = "Count"

    namespace   = "AWS/DynamoDB"
    metric_name = "ConsumedReadCapacityUnits"
    statistic   = "Maximum"
  },
  {
    actions_enabled     = true
    alarm_name          = "dynamodb-consumed-write-capacity-units"
    alarm_description   = "Consumed Write Capacity Units"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    datapoints_to_alarm = null
    threshold           = 10 #TODO this threashold should be equal to the Write Capacy Unit.
    period              = 300
    unit                = "Count"

    namespace   = "AWS/DynamoDB"
    metric_name = "ConsumedWriteCapacityUnits"
    statistic   = "Maximum"
  },
  {
    actions_enabled     = true
    alarm_name          = "dynamodb-read-throttle-events"
    alarm_description   = "Consumed Read Throttle Events"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    datapoints_to_alarm = null
    threshold           = 10 #TODO this threashold should be equal to the Write Capacy Unit.
    period              = 300
    unit                = "Count"

    namespace   = "AWS/DynamoDB"
    metric_name = "ReadThrottleEvents"
    statistic   = "Maximum"
  },
  {
    actions_enabled     = true
    alarm_name          = "dynamodb-write-throttle-events"
    alarm_description   = "Consumed Write Throttle Events"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    datapoints_to_alarm = null
    threshold           = 10 #TODO this threashold should be equal to the Write Capacy Unit.
    period              = 300
    unit                = "Count"

    namespace   = "AWS/DynamoDB"
    metric_name = "WriteThrottleEvents"
    statistic   = "Maximum"
  },
]

tags = {
  CreatedBy   = "Terraform"
  Environment = "Dev"
  Owner       = "Personal Data Vault"
  Source      = "https://github.com/pagopa/pdv-user-registry-infra.git"
  CostCenter  = "TS310 - PAGAMENTI e SERVIZI"
}
