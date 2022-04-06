env_short = "u"


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

tags = {
  CreatedBy   = "Terraform"
  Environment = "Uat"
  Owner       = "Personal Data Vault"
  Source      = "https://github.com/pagopa/private-data-vault-infra.git"
  CostCenter  = "TS310 - PAGAMENTI e SERVIZI"
}