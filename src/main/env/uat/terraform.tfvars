env_short   = "u"
environment = "uat"


# Ecs
ecs_enable_execute_command = true

public_dns_zones = {
  "uat.pdv.pagopa.it" = {
    comment = "Personal data vault (Uat)"

  }
}

apigw_custom_domain_create = true
apigw_api_person_enable    = true
apigw_access_logs_enable   = false

# dynamodb
dynamodb_point_in_time_recovery_enabled = false

dynamodb_alarms = [{
  actions_enabled     = true
  alarm_name          = "dynamodb-account-provisioned-read-capacity"
  alarm_description   = "Account provisioned read capacity greater than 80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 80
  period              = 60
  unit                = "Percent"

  namespace   = "AWS/DynamoDB"
  metric_name = "AccountProvisionedReadCapacityUtilization"
  statistic   = "Maximum"
  }, {
  actions_enabled     = true
  alarm_name          = "dynamodb-account-provisioned-write-capacity"
  alarm_description   = "Account provisioned read capacity greater than 80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 80
  period              = 60
  unit                = "Percent"

  namespace   = "AWS/DynamoDB"
  metric_name = "AccountProvisionedWriteCapacityUtilization"
  statistic   = "Maximum"
}, ]

tags = {
  CreatedBy   = "Terraform"
  Environment = "Uat"
  Owner       = "Personal Data Vault"
  Source      = "https://github.com/pagopa/personal-data-vault-infra.git"
  CostCenter  = "TS310 - PAGAMENTI e SERVIZI"
}