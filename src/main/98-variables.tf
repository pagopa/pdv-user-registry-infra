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

### VPC Peering
variable "vpc_peering" {
  type = object({
    peer_vpc_id         = string
    peer_owner_id       = string
    peer_profile        = string
    accepter_cidr_block = string
  })
  default     = null
  description = "Vpc peering configuration"
}

## Public Dns zones
variable "public_dns_zones" {
  type        = map(any)
  description = "Route53 Hosted Zone"
}

variable "dns_record_ttl" {
  type        = number
  description = "Dns record ttl (in sec)"
  default     = 86400 # 24 hours
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

variable "apigw_execution_logs_retention" {
  type        = number
  default     = 7
  description = "Api gateway exection logs retention (days)"
}

variable "apigw_data_trace_enabled" {
  type        = bool
  description = "Specifies whether data trace logging is enabled. It effects the log entries pushed to Amazon CloudWatch Logs."
  default     = false
}

// We assume every plan has its own api key
variable "user_registry_plans" {
  type = list(object({
    key_name        = string
    burst_limit     = number
    rate_limit      = number
    additional_keys = list(string)
    method_throttle = list(object({
      path        = string
      burst_limit = number
      rate_limit  = number
    }))
  }))
  description = "Usage plan with its api key and rate limit."
}

/*
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
  description = "Api user registry plan rate limits. Important !!! The precedence is granted to the lower values."
}
*/

## Web acl config
variable "web_acl_visibility_config" {
  type = object({
    cloudwatch_metrics_enabled = bool
    sampled_requests_enabled   = bool
  })
  default = {
    cloudwatch_metrics_enabled = false
    sampled_requests_enabled   = false
  }
  description = "Cloudwatch metric eneble for web acl rules."
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
  default     = 7
}

variable "ecs_enable_execute_command" {
  type        = bool
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service."
  default     = false
}

variable "enable_container_insights" {
  type        = bool
  description = "Enable ecs container insight."
  default     = false
}

variable "ms_tokenizer_host_name" {
  type        = string
  description = "Toknizer host name. It should be the internal network load balancer."
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

variable "replica_count" {
  type        = number
  description = "Number of task replica"
  default     = 1
}

variable "person_task" {
  type = object({
    image_version = string
    cpu           = number
    mem           = number
    container_cpu = number
    container_mem = number
  })
  default = {
    image_version = "latest"
    cpu           = 256
    mem           = 512
    container_cpu = 256
    container_mem = 512
  }
}

variable "x_ray_daemon_container_cpu" {
  type        = number
  description = "Container cpu quota."
  default     = 32
}

variable "x_ray_daemon_container_memory" {
  type        = number
  description = "Container memory quota."
  default     = 256
}

variable "user_registry_task" {
  type = object({
    image_version = string
    cpu           = number
    mem           = number
    container_cpu = number
    container_mem = number
  })
  default = {
    image_version = "latest"
    cpu           = 256
    mem           = 512
    container_cpu = 256
    container_mem = 512
  }
}

# x-ray
variable "publish_x-ray_image" {
  type        = bool
  description = "Run docker command to push x-ray image"
  default     = false
}

variable "x_ray_daemon_image_version" {
  type        = string
  description = "Image version in task definition"
  default     = "latest"
}

variable "x_ray_daemon_image_uri" {
  type        = string
  description = "X-Ray daemon image URI"
  default     = "public.ecr.aws/xray/aws-xray-daemon"
}

variable "x_ray_daemon_image_sha" {
  type        = string
  description = "X-Ray daemon image sha"
  default     = "sha256:9f3e1362e1e986fc5e631389b499068e1db82762e6fdb572ed6b5e54b43f0744"
}

variable "ecs_autoscaling" {
  type = object({
    max_capacity       = number
    min_capacity       = number
    scale_in_cooldown  = number
    scale_out_cooldown = number
  })
  default = {
    max_capacity       = 3
    min_capacity       = 1
    scale_in_cooldown  = 180
    scale_out_cooldown = 40
  }

  description = "ECS Service autoscaling."
}

variable "ecs_as_threshold" {
  type = object({
    cpu_min = number
    cpu_max = number
    mem_min = number
    mem_max = number
  })
  default = {
    cpu_max = 80
    cpu_min = 20
    mem_max = 80
    mem_min = 60
  }
  description = "ECS Tasks autoscaling settings."
}

variable "ms_tokenizer_rest_client_log_level" {
  type        = string
  default     = "FULL"
  description = "Rest client log level micro service tokenizer"
}

variable "ms_person_log_level" {
  type        = string
  default     = "DEBUG"
  description = "Log lever micro service person"
}

variable "ms_person_rest_client_log_level" {
  type        = string
  default     = "FULL"
  description = "Rest client log level micro service person"
}

variable "ms_person_enable_confidential_filter" {
  type        = bool
  default     = false
  description = "Enable a filter to avoid logging confidential data"
}

variable "ms_person_enable_single_line_stack_trace_logging" {
  type        = bool
  default     = false
  description = "Enable logging stack trace in a single line"
}

variable "ms_user_registry_log_level" {
  type        = string
  default     = "DEBUG"
  description = "Log level micro service user registry"
}

variable "ms_user_registry_rest_client_log_level" {
  type        = string
  default     = "FULL"
  description = "Rest client log level micro service user registry"
}

variable "ms_user_registry_enable_confidential_filter" {
  type        = bool
  default     = false
  description = "Enable a filter to avoid logging confidential data"
}

variable "ms_user_registry_enable_single_line_stack_trace_logging" {
  type        = bool
  default     = false
  description = "Enable logging stack trace in a single line"
}

variable "github_person_repo" {
  type        = string
  description = "Github repository ms Person code."
  default     = "pagopa/pdv-ms-person"
}

variable "github_user_registry_repo" {
  type        = string
  description = "Github repository ms User registry."
  default     = "pagopa/pdv-ms-user-registry"
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

variable "create_cloudhsm" {
  type        = bool
  description = "Create cloudhsm cluster to enctypt dynamodb tables"
  default     = false
}

variable "cloudhsm_nodes" {
  type        = number
  default     = 1
  description = "Number of HSMs in the cluset. One and only one is required to initialize the cluster. Two are required to create a key store in KMS."
}


## Alarms

variable "enable_opsgenie" {
  type        = bool
  default     = false
  description = "Send alarm via opsgenie."
}


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

# Sentinel integration
variable "enable_sentinel_logs" {
  type        = bool
  default     = false
  description = "Create all resources required to sento logs to azure sentinel."
}

variable "sentinel_servcie_account_id" {
  type        = string
  description = "Microsoft Sentinel's service account ID for AWS."
  default     = "197857026523"
}

variable "sentinel_workspace_id" {
  type        = string
  description = "Sentinel workspece id"
  default     = null

}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}
