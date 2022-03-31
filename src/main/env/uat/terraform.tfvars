env_short = "u"


public_dns_zones = {
  "uat.pdv.pagopa.it" = {
    comment = "Personal data vault (Uat)"
    tags = {
      Environment = "Uat"
    }
  }
}


# Ecs
ecs_enable_execute_command = true


tags = {
  CreatedBy   = "Terraform"
  Environment = "Uat"
  Owner       = "Private Data Vault"
  Source      = "https://github.com/pagopa/private-data-vault-infra.git"
  CostCenter  = "TS310 - PAGAMENTI e SERVIZI"
}