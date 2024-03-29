env_short   = "u"
environment = "uat"

# Network
enable_nat_gateway = false

## Vpc peering
vpc_peering = {
  peer_vpc_id         = "vpc-06fce5f8ff25299ea"
  peer_owner_id       = "377122414966"
  peer_profile        = "ppa-tokenizer-data-vault-uat"
  accepter_cidr_block = "10.1.0.0/16"
}

# Ecs
ecs_enable_execute_command = true
# Ecs
replica_count = 3

ecs_autoscaling = {
  max_capacity       = 10
  min_capacity       = 3
  scale_in_cooldown  = 900 # 15mins
  scale_out_cooldown = 60  # 1 min
}

person_task = {
  image_version = "12f9052eebc1277c569dbb9305357a306b0c6fc0"
  cpu           = 1024
  mem           = 2048
  container_cpu = 1024
  container_mem = 2048
}

user_registry_task = {
  image_version = "1e2acef4f85f3ecfaa465ef90f7a3a6b90f192e7"
  cpu           = 1024
  mem           = 2048
  container_cpu = 1024
  container_mem = 2048
}

x_ray_daemon_container_cpu    = 32
x_ray_daemon_container_memory = 256

ms_tokenizer_host_name = "tokenizer-u-nlb-63e5a0a1a5a8c188.elb.eu-south-1.amazonaws.com"

public_dns_zones = {
  "uat.pdv.pagopa.it" = {
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
  {
    key_name        = "SELFCARE-DEV"
    burst_limit     = 20
    rate_limit      = 10
    additional_keys = ["INTEROP-DEV"]
    method_throttle = []
  },
  {
    key_name        = "SELFCARE-UAT"
    burst_limit     = 20
    rate_limit      = 10
    additional_keys = ["INTEROP-UAT"]
    method_throttle = []
  },
  {
    # Piattaforma Notifiche Persone Fisiche
    key_name        = "PNPF-DEV"
    burst_limit     = 600
    rate_limit      = 300
    additional_keys = []
    method_throttle = []
  },
  {
    key_name        = "PNPF-UAT"
    burst_limit     = 600
    rate_limit      = 300
    additional_keys = []
    method_throttle = []
  },
  {
    key_name        = "PNPF-CERT"
    burst_limit     = 600
    rate_limit      = 300
    additional_keys = []
    method_throttle = []
  },
  {
    # Piattaforma Notifiche Persone Giuridiche
    key_name        = "PNPG"
    burst_limit     = 600
    rate_limit      = 300
    additional_keys = []
    method_throttle = []
  },
  {
    key_name        = "IDPAY-DEV"
    burst_limit     = 200
    rate_limit      = 100
    additional_keys = []
    method_throttle = []
  },
  {
    key_name        = "IDPAY-UAT"
    burst_limit     = 200
    rate_limit      = 100
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


# dynamodb
dynamodb_point_in_time_recovery_enabled = false

## alarms

enable_opsgenie = false

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
  Environment = "Uat"
  Owner       = "Personal Data Vault"
  Source      = "https://github.com/pagopa/pdv-user-registry-infra.git"
  CostCenter  = "TS310 - PAGAMENTI e SERVIZI"
}
