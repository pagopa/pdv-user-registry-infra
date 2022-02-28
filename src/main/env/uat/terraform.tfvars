env_short = "u"

public_dns_zones = {
  "uat.ur.pagopa.it" = {
    comment = "User registry (Uat)"
    tags = {
      Environment = "Uat"
    }
  }
}

tags = {
  CreatedBy   = "Terraform"
  Environment = "Uat"
  Owner       = "Private Data Vault"
  Source      = "https://github.com/pagopa/private-data-vault-infra.git"
  CostCenter  = "TS310 - PAGAMENTI e SERVIZI"
}