env_short   = "p"
environment = "prod"

public_dns_zones = {
  "pdv.pagopa.it" = {
    comment = "Personal data vault (Prod)"
  }
}

# Network
enable_nat_gateway = false

vpc_peering = {
  peer_vpc_id         = "vpc-04e328a57c3f3d784"
  peer_owner_id       = "449227190332"
  peer_profile        = "ppa-tokenizer-data-vault-prod"
  accepter_cidr_block = "10.1.0.0/16"
}

# Ecs
ecs_enable_execute_command = true
replica_count              = 2

ecs_autoscaling = {
  max_capacity = 5
  min_capacity = 2
}

ecs_logs_retention_days                     = 90

ms_tokenizer_host_name = "tokenizer-p-nlb-094463a88e36e754.elb.eu-south-1.amazonaws.com"


# App
ms_person_log_level                                     = "INFO"
ms_person_rest_client_log_level                         = "BASIC"
ms_person_enable_confidential_filter                    = true
ms_person_enable_single_line_stack_trace_logging        = true
ms_user_registry_log_level                              = "INFO"
ms_user_registry_rest_client_log_level                  = "BASIC"
ms_user_registry_enable_confidential_filter             = true
ms_user_registry_enable_single_line_stack_trace_logging = true


# Api Gateway

apigw_custom_domain_create     = true
apigw_access_logs_enable       = false
apigw_execution_logs_retention = 90

user_registry_plans = [
  {
    key_name    = "SELFCARE"
    burst_limit = 10
    rate_limit  = 20

    method_throttle = [
      {
        burst_limit = 5
        path        = "/users/{id}/GET"
        rate_limit  = 18
      },
      {
        burst_limit = 5
        path        = "/users/PATCH"
        rate_limit  = 18
      },
      {
        burst_limit = 5
        path        = "/users/search/POST"
        rate_limit  = 38
      },
      {
        burst_limit = 5
        path        = "/users/{id}/DELETE"
        rate_limit  = 2
      },
      {
        burst_limit = 5
        path        = "/users/{id}/PATCH"
        rate_limit  = 18
      }
    ]
  },
  {
    key_name    = "INTEROP"
    burst_limit = 10
    rate_limit  = 20

    method_throttle = [
      {
        burst_limit = 5
        path        = "/users/{id}/GET"
        rate_limit  = 18
      },
      {
        burst_limit = 5
        path        = "/users/PATCH"
        rate_limit  = 18
      },
      {
        burst_limit = 5
        path        = "/users/search/POST"
        rate_limit  = 38
      },
      {
        burst_limit = 5
        path        = "/users/{id}/DELETE"
        rate_limit  = 2
      },
      {
        burst_limit = 5
        path        = "/users/{id}/PATCH"
        rate_limit  = 18
      }
    ]
  },
  {
    key_name    = "TEST"
    burst_limit = 10
    rate_limit  = 20

    method_throttle = [
      {
        burst_limit = 5
        path        = "/users/{id}/GET"
        rate_limit  = 18
      },
      {
        burst_limit = 5
        path        = "/users/PATCH"
        rate_limit  = 18
      },
      {
        burst_limit = 5
        path        = "/users/search/POST"
        rate_limit  = 38
      },
      {
        burst_limit = 5
        path        = "/users/{id}/DELETE"
        rate_limit  = 2
      },
      {
        burst_limit = 5
        path        = "/users/{id}/PATCH"
        rate_limit  = 18
      }
    ]
  },
]


## Web ACL

web_acl_visibility_config = {
  cloudwatch_metrics_enabled = true
  sampled_requests_enabled   = true
}

# DynamoDB
dynamodb_point_in_time_recovery_enabled = true
dynamodb_region_replication_enable      = true

## table Person
table_person_read_capacity  = 50
table_person_write_capacity = 40

table_person_autoscaling_read = {
  scale_in_cooldown  = 50
  scale_out_cooldown = 40
  target_value       = 40
  max_capacity       = 60
}

table_person_autoscaling_write = {
  scale_in_cooldown  = 50
  scale_out_cooldown = 40
  target_value       = 20
  max_capacity       = 50
}

table_person_autoscling_indexes = {
  gsi_namespaced_id = {
    read_max_capacity  = 30
    read_min_capacity  = 10
    write_max_capacity = 20
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

create_cloudhsm = false
cloudhsm_nodes  = 1 # change to 2 once you downloaded the certificates and the cluster is initialized and active.

enable_sentinel_logs  = true
sentinel_workspace_id = "a6cbd2fb-37c2-4f23-bc46-311585b62a52"

tags = {
  CreatedBy   = "Terraform"
  Environment = "Prod"
  Owner       = "Personal Data Vault"
  Source      = "https://github.com/pagopa/personal-data-vault-infra.git"
  CostCenter  = "TS310 - PAGAMENTI e SERVIZI"
}