## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.10.0 |
| <a name="provider_aws.eu-central-1"></a> [aws.eu-central-1](#provider\_aws.eu-central-1) | >= 4.10.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dn_zone"></a> [dn\_zone](#module\_dn\_zone) | terraform-aws-modules/route53/aws//modules/zones | ~> 2.0 |
| <a name="module_dynamo_successful_request_latency"></a> [dynamo\_successful\_request\_latency](#module\_dynamo\_successful\_request\_latency) | terraform-aws-modules/cloudwatch/aws//modules/metric-alarm | ~> 3.0 |
| <a name="module_dynamodb_table_person"></a> [dynamodb\_table\_person](#module\_dynamodb\_table\_person) | terraform-aws-modules/dynamodb-table/aws |  |
| <a name="module_metric_alarms"></a> [metric\_alarms](#module\_metric\_alarms) | terraform-aws-modules/cloudwatch/aws//modules/metric-alarm | ~> 3.0 |
| <a name="module_nlb"></a> [nlb](#module\_nlb) | terraform-aws-modules/alb/aws |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.14.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints |  |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_api_gateway_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_api_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_api_key) | resource |
| [aws_api_gateway_api_key.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_api_key) | resource |
| [aws_api_gateway_base_path_mapping.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_base_path_mapping.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_deployment.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_deployment.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_domain_name.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_method_settings.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_method_settings.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_rest_api.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_rest_api.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_stage.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_usage_plan.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan_key.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |
| [aws_api_gateway_usage_plan_key.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |
| [aws_api_gateway_vpc_link.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_vpc_link) | resource |
| [aws_appautoscaling_policy.app_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.app_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_policy_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_policy_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudhsm_v2_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudhsm_v2_cluster) | resource |
| [aws_cloudwatch_log_group.ecs_person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ecs_poc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ecs_user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization_low](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecr_lifecycle_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.poc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.poc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_access_key.deploy_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_group.developers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.deny_secrets_devops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_group_policy_attachment.power_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.deny_secrets_devops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.deploy_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dynamodb_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_allow_hsm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_allow_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.execute_command_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_execution_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecsTaskExecutionRole_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_allow_hsm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_allow_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_dynamodb_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_execute_command_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.deploy_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.deploy_ec2_ecr_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.deploy_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_kms_alias.dynamo_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.dynamo_db_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.dynamo_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.dynamo_db_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route.owner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.uat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.nsg_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.nsg_task_egress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nsg_task_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sns_topic.alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.alarms_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_vpc_peering_connection.owner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_wafv2_web_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_association.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [null_resource.vpc_peering](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_task_definition.person](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_ecs_task_definition.poc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_ecs_task_definition.user_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy.ec2_ecr_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.power_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.dynamodb_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_tasks_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.generic_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_network_interface.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interface) | data source |
| [aws_route_tables.owner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_secretsmanager_secret.devops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.email_operation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.email_operation_lt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dynamodb_alarms"></a> [dynamodb\_alarms](#input\_dynamodb\_alarms) | # Alarms | <pre>list(<br>    object({<br>      actions_enabled     = bool<br>      alarm_name          = string<br>      alarm_description   = string<br>      comparison_operator = string<br>      evaluation_periods  = number<br>      datapoints_to_alarm = number<br>      threshold           = number<br>      period              = number<br>      unit                = string<br>      namespace           = string<br>      metric_name         = string<br>      statistic           = string<br>  }))</pre> | n/a | yes |
| <a name="input_ms_tokenizer_host_name"></a> [ms\_tokenizer\_host\_name](#input\_ms\_tokenizer\_host\_name) | Toknizer host name. It should be the internal network load balancer. | `string` | n/a | yes |
| <a name="input_public_dns_zones"></a> [public\_dns\_zones](#input\_public\_dns\_zones) | Route53 Hosted Zone | `map(any)` | n/a | yes |
| <a name="input_table_person_autoscaling_read"></a> [table\_person\_autoscaling\_read](#input\_table\_person\_autoscaling\_read) | Read autoscaling settings table person. | <pre>object({<br>    scale_in_cooldown  = number<br>    scale_out_cooldown = number<br>    target_value       = number<br>    max_capacity       = number<br>  })</pre> | n/a | yes |
| <a name="input_table_person_autoscaling_write"></a> [table\_person\_autoscaling\_write](#input\_table\_person\_autoscaling\_write) | Write autoscaling settings table person. | <pre>object({<br>    scale_in_cooldown  = number<br>    scale_out_cooldown = number<br>    target_value       = number<br>    max_capacity       = number<br>  })</pre> | n/a | yes |
| <a name="input_table_person_autoscling_indexes"></a> [table\_person\_autoscling\_indexes](#input\_table\_person\_autoscling\_indexes) | Autoscaling gsi configurations | `any` | n/a | yes |
| <a name="input_table_person_read_capacity"></a> [table\_person\_read\_capacity](#input\_table\_person\_read\_capacity) | Table person read capacity. | `number` | n/a | yes |
| <a name="input_table_person_write_capacity"></a> [table\_person\_write\_capacity](#input\_table\_person\_write\_capacity) | Table person read capacity. | `number` | n/a | yes |
| <a name="input_api_keys_user_registry"></a> [api\_keys\_user\_registry](#input\_api\_keys\_user\_registry) | Api keys allowed to call the user registry ms. | `list(string)` | <pre>[<br>  "SELFCARE"<br>]</pre> | no |
| <a name="input_api_user_registry_throttling"></a> [api\_user\_registry\_throttling](#input\_api\_user\_registry\_throttling) | Api user registry plan rate limits. Important !!! The precedence is granted to the lower values. | <pre>object({<br>    burst_limit = number<br>    rate_limit  = number<br>    method_throttle = list(object({<br>      path        = string<br>      burst_limit = number<br>      rate_limit  = number<br>    }))<br>  })</pre> | <pre>{<br>  "burst_limit": 5,<br>  "method_throttle": [],<br>  "rate_limit": 10<br>}</pre> | no |
| <a name="input_apigw_access_logs_enable"></a> [apigw\_access\_logs\_enable](#input\_apigw\_access\_logs\_enable) | Enable api gateway access logs | `bool` | `false` | no |
| <a name="input_apigw_api_person_enable"></a> [apigw\_api\_person\_enable](#input\_apigw\_api\_person\_enable) | Create api person. This is supposed to be internal and should not be shown. | `bool` | `false` | no |
| <a name="input_apigw_custom_domain_create"></a> [apigw\_custom\_domain\_create](#input\_apigw\_custom\_domain\_create) | Create apigw Custom Domain with its tls certificate | `bool` | `false` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name. Personal Data Vault | `string` | `"pdv"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources. Default Milan | `string` | `"eu-south-1"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability zones | `list(string)` | <pre>[<br>  "eu-south-1a",<br>  "eu-south-1b",<br>  "eu-south-1c"<br>]</pre> | no |
| <a name="input_container_port_person"></a> [container\_port\_person](#input\_container\_port\_person) | Container port person | `number` | `8000` | no |
| <a name="input_container_port_poc"></a> [container\_port\_poc](#input\_container\_port\_poc) | n/a | `number` | `8060` | no |
| <a name="input_container_port_user_registry"></a> [container\_port\_user\_registry](#input\_container\_port\_user\_registry) | Container port service user registry. | `number` | `8090` | no |
| <a name="input_create_cloudhsm"></a> [create\_cloudhsm](#input\_create\_cloudhsm) | Create cloudhsm cluster to enctypt dynamodb tables | `bool` | `false` | no |
| <a name="input_dynamodb_point_in_time_recovery_enabled"></a> [dynamodb\_point\_in\_time\_recovery\_enabled](#input\_dynamodb\_point\_in\_time\_recovery\_enabled) | Enable dynamodb point in time recovery | `bool` | `false` | no |
| <a name="input_dynamodb_region_replication_enable"></a> [dynamodb\_region\_replication\_enable](#input\_dynamodb\_region\_replication\_enable) | Enable dyamodb deplicaton in a secondary region. | `bool` | `false` | no |
| <a name="input_ecr_keep_nr_images"></a> [ecr\_keep\_nr\_images](#input\_ecr\_keep\_nr\_images) | Number of images to keep. | `number` | `10` | no |
| <a name="input_ecs_as_cpu_high_threshold"></a> [ecs\_as\_cpu\_high\_threshold](#input\_ecs\_as\_cpu\_high\_threshold) | ECS Scale out CPU % threshord | `number` | `80` | no |
| <a name="input_ecs_as_cpu_low_threshold"></a> [ecs\_as\_cpu\_low\_threshold](#input\_ecs\_as\_cpu\_low\_threshold) | ECS Scale in CPU % threshord | `number` | `20` | no |
| <a name="input_ecs_autoscaling"></a> [ecs\_autoscaling](#input\_ecs\_autoscaling) | ECS Service autoscaling. | <pre>object({<br>    max_capacity = number<br>    min_capacity = number<br>  })</pre> | <pre>{<br>  "max_capacity": 3,<br>  "min_capacity": 1<br>}</pre> | no |
| <a name="input_ecs_enable_execute_command"></a> [ecs\_enable\_execute\_command](#input\_ecs\_enable\_execute\_command) | Specifies whether to enable Amazon ECS Exec for the tasks within the service. | `bool` | `false` | no |
| <a name="input_ecs_logs_retention_days"></a> [ecs\_logs\_retention\_days](#input\_ecs\_logs\_retention\_days) | Specifies the number of days you want to retain log events in the specified log group. | `number` | `90` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Enable/Create nat gateway | `bool` | `false` | no |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Evnironment short. | `string` | `"d"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | `"dev"` | no |
| <a name="input_ms_person_enable_confidential_filter"></a> [ms\_person\_enable\_confidential\_filter](#input\_ms\_person\_enable\_confidential\_filter) | Enable a filter to avoid logging confidential data | `bool` | `false` | no |
| <a name="input_ms_person_log_level"></a> [ms\_person\_log\_level](#input\_ms\_person\_log\_level) | Log lever micro service person | `string` | `"DEBUG"` | no |
| <a name="input_ms_person_rest_client_log_level"></a> [ms\_person\_rest\_client\_log\_level](#input\_ms\_person\_rest\_client\_log\_level) | Rest client log level micro service person | `string` | `"FULL"` | no |
| <a name="input_ms_tokenizer_rest_client_log_level"></a> [ms\_tokenizer\_rest\_client\_log\_level](#input\_ms\_tokenizer\_rest\_client\_log\_level) | Rest client log level micro service tokenizer | `string` | `"FULL"` | no |
| <a name="input_ms_user_registry_enable_confidential_filter"></a> [ms\_user\_registry\_enable\_confidential\_filter](#input\_ms\_user\_registry\_enable\_confidential\_filter) | Enable a filter to avoid logging confidential data | `bool` | `false` | no |
| <a name="input_ms_user_registry_log_level"></a> [ms\_user\_registry\_log\_level](#input\_ms\_user\_registry\_log\_level) | Log level micro service user registry | `string` | `"DEBUG"` | no |
| <a name="input_ms_user_registry_rest_client_log_level"></a> [ms\_user\_registry\_rest\_client\_log\_level](#input\_ms\_user\_registry\_rest\_client\_log\_level) | Rest client log level micro service user registry | `string` | `"FULL"` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of task replica | `number` | `1` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "CreatedBy": "Terraform"<br>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC cidr. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_internal_subnets_cidr"></a> [vpc\_internal\_subnets\_cidr](#input\_vpc\_internal\_subnets\_cidr) | Internal subnets list of cidr. Mainly for private endpoints | `list(string)` | <pre>[<br>  "10.0.201.0/24",<br>  "10.0.202.0/24",<br>  "10.0.203.0/24"<br>]</pre> | no |
| <a name="input_vpc_peering"></a> [vpc\_peering](#input\_vpc\_peering) | Vpc peering configuration | <pre>object({<br>    peer_vpc_id         = string<br>    peer_owner_id       = string<br>    peer_profile        = string<br>    accepter_cidr_block = string<br>  })</pre> | `null` | no |
| <a name="input_vpc_private_subnets_cidr"></a> [vpc\_private\_subnets\_cidr](#input\_vpc\_private\_subnets\_cidr) | Private subnets list of cidr. | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_vpc_public_subnets_cidr"></a> [vpc\_public\_subnets\_cidr](#input\_vpc\_public\_subnets\_cidr) | Private subnets list of cidr. | `list(string)` | <pre>[<br>  "10.0.101.0/24",<br>  "10.0.102.0/24",<br>  "10.0.103.0/24"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_endpoint"></a> [api\_gateway\_endpoint](#output\_api\_gateway\_endpoint) | n/a |
| <a name="output_cloudhsm_cluster_certificates"></a> [cloudhsm\_cluster\_certificates](#output\_cloudhsm\_cluster\_certificates) | n/a |
| <a name="output_cloudhsm_cluster_id"></a> [cloudhsm\_cluster\_id](#output\_cloudhsm\_cluster\_id) | cloud hsm |
| <a name="output_deploy_access_key"></a> [deploy\_access\_key](#output\_deploy\_access\_key) | n/a |
| <a name="output_deploy_access_key_secret"></a> [deploy\_access\_key\_secret](#output\_deploy\_access\_key\_secret) | n/a |
| <a name="output_dynamodb_table_person_arn"></a> [dynamodb\_table\_person\_arn](#output\_dynamodb\_table\_person\_arn) | # dynamodb |
| <a name="output_dynamodb_table_person_id"></a> [dynamodb\_table\_person\_id](#output\_dynamodb\_table\_person\_id) | n/a |
| <a name="output_ecs_task_definition_person_arn"></a> [ecs\_task\_definition\_person\_arn](#output\_ecs\_task\_definition\_person\_arn) | # ecs |
| <a name="output_ecs_task_definition_person_revision"></a> [ecs\_task\_definition\_person\_revision](#output\_ecs\_task\_definition\_person\_revision) | n/a |
| <a name="output_nlb_hostname"></a> [nlb\_hostname](#output\_nlb\_hostname) | NLB |
| <a name="output_person_api_key"></a> [person\_api\_key](#output\_person\_api\_key) | n/a |
| <a name="output_personinvoke_url"></a> [personinvoke\_url](#output\_personinvoke\_url) | n/a |
| <a name="output_public_dns_servers"></a> [public\_dns\_servers](#output\_public\_dns\_servers) | n/a |
| <a name="output_public_dns_zone_name"></a> [public\_dns\_zone\_name](#output\_public\_dns\_zone\_name) | Dns |
| <a name="output_user_registry_api_ids"></a> [user\_registry\_api\_ids](#output\_user\_registry\_api\_ids) | n/a |
| <a name="output_user_registry_api_keys"></a> [user\_registry\_api\_keys](#output\_user\_registry\_api\_keys) | n/a |
| <a name="output_user_registryinvoke_url"></a> [user\_registryinvoke\_url](#output\_user\_registryinvoke\_url) | n/a |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | n/a |
| <a name="output_vpc_peering_id"></a> [vpc\_peering\_id](#output\_vpc\_peering\_id) | n/a |
| <a name="output_vpc_peering_status"></a> [vpc\_peering\_status](#output\_vpc\_peering\_status) | n/a |
