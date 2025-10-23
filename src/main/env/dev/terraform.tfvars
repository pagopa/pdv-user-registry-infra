env_short   = "d"
environment = "dev"

# Network
enable_nat_gateway = false

# One Identity integration
oi_integration_vpc_endpoint_id = "vpce-06b505f7afb12a154"

## Vpc peering
vpc_peering = {
  peer_vpc_id         = "vpc-04c3316f3b4cc2c65"
  peer_owner_id       = "209688138459"
  peer_profile        = "ppa-tokenizer-data-vault-dev"
  accepter_cidr_block = "10.1.0.0/16"
}

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
  image_version = "99082c1325b915eb523b13258fbdf54dbace248c"
  cpu           = 256
  mem           = 512
  container_cpu = 256
  container_mem = 512
}

user_registry_task = {
  image_version = "5d94ab36f4c8cf31d625007303f2181b21254e76"
  cpu           = 1024
  mem           = 2048
  container_cpu = 1024
  container_mem = 2048
}

x_ray_daemon_container_cpu    = 32
x_ray_daemon_container_memory = 256
publish_x-ray_image           = false

ms_tokenizer_host_name = "tokenizer-d-nlb-43d3fb6b08d9e0c6.elb.eu-south-1.amazonaws.com"

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
  # Github Action Key for Integration Testing
  {
    key_name        = "GITHUB-KEY"
    burst_limit     = 20
    rate_limit      = 10
    additional_keys = []
    method_throttle = []
  },
]

plan_details_plans = [
  {
    key_name        = "PLAN-DETAILS"
    burst_limit     = 20
    rate_limit      = 10
    additional_keys = []
    method_throttle = []
  },
]


# dynamodb
dynamodb_point_in_time_recovery_enabled = false

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
