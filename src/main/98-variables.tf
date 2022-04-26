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
  default     = "dev"
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

variable "vpc_internal_subnets_cidr" {
  type        = list(string)
  description = "Internal subnets list of cidr. Mainly for private endpoints"
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable/Create nat gateway"
  default     = false
}

## Public Dns zones
variable "public_dns_zones" {
  type        = map(any)
  description = "Route53 Hosted Zone"
}

## Api Gateway
variable "apigw_custom_domain_create" {
  type        = bool
  description = "Create apigw Custom Domain with its tls certificate"
  default     = false
}

variable "apigw_access_logs_enable" {
  type        = bool
  description = "Enable api gateway access logs"
  default     = false

}

variable "apigw_api_person_enable" {
  type        = bool
  description = "Create api person. This is supposed to be internal and should not be shown."
  default     = false
}

variable "api_keys_tokenizer" {
  type        = list(string)
  description = "Api keys allowed to call the tokenizer ms."
  default     = ["SELFCARE", "USERREGISTRY", ]
}

variable "api_keys_user_registry" {
  type        = list(string)
  description = "Api keys allowed to call the tokenizer ms."
  default     = ["SELFCARE", ]
}

variable "api_tokenizer_throttling" {
  type = object({
    burst_limit = number
    rate_limit  = number
    method_throttle = list(object({
      path        = string
      burst_limit = number
      rate_limit  = number
    }))
  })
  default = {
    burst_limit     = 5
    rate_limit      = 10
    method_throttle = []
  }
  description = "Api tokenizer plan rate limits."
}

variable "api_user_registry_throttling" {
  type = object({
    burst_limit = number
    rate_limit  = number
    method_throttle = list(object({
      path        = string
      burst_limit = number
      rate_limit  = number
    }))
  })
  default = {
    burst_limit     = 5
    rate_limit      = 10
    method_throttle = []
  }
  description = "Api user registry plan rate limits."
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

variable "container_port_tokenizer" {
  type        = number
  description = "Container port tokenizer"
  default     = 8080
}

variable "container_port_person" {
  type        = number
  description = "Container port person"
  default     = 8000
}

variable "container_port_user_registry" {
  type        = number
  description = "Container port service user registry."
  default     = 8090
}

variable "container_port_poc" {
  type    = number
  default = 8060

}

variable "replica_count" {
  type        = number
  description = "Number of task replica"
  default     = 1
}

variable "ecs_autoscaling" {
  type = object({
    max_capacity = number
    min_capacity = number
  })
  default = {
    max_capacity = 3
    min_capacity = 1
  }

  description = "ECS Service autoscaling."
}

variable "ecs_as_cpu_low_threshold" {
  type        = number
  default     = 20
  description = "ECS Scale in CPU % threshord"
}

variable "ecs_as_cpu_high_threshold" {
  type        = number
  default     = 80
  description = "ECS Scale out CPU % threshord"
}

variable "ms_tokenizer_log_level" {
  type        = string
  default     = "DEBUG"
  description = "Log lever micro service tokenizer"
}

variable "ms_person_log_level" {
  type        = string
  default     = "DEBUG"
  description = "Log lever micro service person"
}

variable "ms_user_registry_log_level" {
  type        = string
  default     = "DEBUG"
  description = "Log lever micro service user registry"
}

# Dynamodb 
variable "dynamodb_region_replication_enable" {
  type        = bool
  description = "Enable dyamodb deplicaton in a secondary region."
  default     = false
}

variable "dynamodb_point_in_time_recovery_enabled" {
  type        = bool
  description = "Enable dynamodb point in time recovery"
  default     = false
}

## Table Person
variable "table_person_read_capacity" {
  type        = number
  description = "Table person read capacity."
}

variable "table_person_write_capacity" {
  type        = number
  description = "Table person read capacity."
}

variable "table_person_autoscaling_read" {
  type = object({
    scale_in_cooldown  = number
    scale_out_cooldown = number
    target_value       = number
    max_capacity       = number
  })
  description = "Read autoscaling settings table person."
}

variable "table_person_autoscaling_write" {
  type = object({
    scale_in_cooldown  = number
    scale_out_cooldown = number
    target_value       = number
    max_capacity       = number
  })
  description = "Write autoscaling settings table person."
}

variable "table_person_autoscling_indexes" {
  type        = any
  description = "Autoscaling gsi configurations"
}

## Table Token
variable "table_token_read_capacity" {
  type        = number
  description = "Table token read capacity."
}

variable "table_token_write_capacity" {
  type        = number
  description = "Table token read capacity."
}

variable "table_token_autoscaling_read" {
  type = object({
    scale_in_cooldown  = number
    scale_out_cooldown = number
    target_value       = number
    max_capacity       = number
  })
  description = "Read autoscaling settings table token."
}

variable "table_token_autoscaling_write" {
  type = object({
    scale_in_cooldown  = number
    scale_out_cooldown = number
    target_value       = number
    max_capacity       = number
  })
  description = "Write autoscaling settings table token."
}

variable "table_token_autoscling_indexes" {
  type        = any
  description = "Autoscaling gsi configurations"
}


## Alarms
variable "dynamodb_alarms" {
  type = list(
    object({
      actions_enabled     = bool
      alarm_name          = string
      alarm_description   = string
      comparison_operator = string
      evaluation_periods  = number
      datapoints_to_alarm = number
      threshold           = number
      period              = number
      unit                = string
      namespace           = string
      metric_name         = string
      statistic           = string
  }))
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}
