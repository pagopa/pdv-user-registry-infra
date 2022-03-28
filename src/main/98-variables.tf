variable "aws_region" {
  type        = string
  description = "AWS region to create resources. Default Milan"
  default     = "eu-south-1"
}

variable "app_name" {
  type        = string
  default     = "pdv"
  description = "App name. Personal Data Vault"

}

variable "environment" {
  type        = string
  default     = "Dev"
  description = "Environment"
}

variable "env_short" {
  type        = string
  default     = "d"
  description = "Evnironment short."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC cidr."
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]
}

variable "vpc_private_subnets_cidr" {
  type        = list(string)
  description = "Private subnets list of cidr."
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnets_cidr" {
  type        = list(string)
  description = "Private subnets list of cidr."
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

## Dns zones

variable "public_dns_zones" {
  type        = map(any)
  description = "Route53 Hosted Zone"
}

variable "vpc_internal_subnets_cidr" {
  type        = list(string)
  description = "Internal subnets list of cidr. Mainly for private endpoints"
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

## ECR

variable "ecr_keep_nr_images" {
  type        = number
  description = "Number of images to keep."
  default     = 10
}


## ECS

variable "ecs_logs_retention_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group."
  default     = 90
}

variable "ecs_enable_execute_command" {
  type        = bool
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service."
  default     = false
}

variable "container_port" {
  type        = number
  description = "Container port"
  default     = 8000

}

variable "replica_count" {
  type        = number
  description = "Number of task replica"
  default     = 1
}

###

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}
