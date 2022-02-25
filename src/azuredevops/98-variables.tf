variable "aws_region" {
  type        = string
  description = "AWS default region"
  default     = "eu-south-1"
}

variable "project_name" {
  type        = string
  description = "Azure devops project name."
  default     = "private-data-vault-iac"
}

variable "iac" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "private-data-vault-infra"
      branch_name     = "refs/heads/main"
      pipelines_path  = ".src/pipelines"
      yml_prefix_name = null
    }
    pipeline = {
      enable_code_review = true
      enable_deploy      = true
    }
  }
}