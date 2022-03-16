## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 3.63.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | > 3.63.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dn_zone"></a> [dn\_zone](#module\_dn\_zone) | terraform-aws-modules/route53/aws//modules/zones | ~> 2.0 |
| <a name="module_dynamodb_table"></a> [dynamodb\_table](#module\_dynamodb\_table) | terraform-aws-modules/dynamodb-table/aws |  |
| <a name="module_nlb"></a> [nlb](#module\_nlb) | terraform-aws-modules/alb/aws |  |
| <a name="module_redis"></a> [redis](#module\_redis) | git::https://github.com/pagopa/terraform-aws-modules.git//elastic-cache-redis?ref=v1.3.3 |  |
| <a name="module_redis_sg"></a> [redis\_sg](#module\_redis\_sg) | git::https://github.com/pagopa/terraform-aws-modules.git//security-group?ref=v1.3.4 |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws |  |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints |  |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_api_key.prod_io](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_api_key) | resource |
| [aws_api_gateway_deployment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_rest_api.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_usage_plan.prod_io](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan_key.prod_io](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |
| [aws_api_gateway_vpc_link.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_vpc_link) | resource |
| [aws_appautoscaling_policy.ecs_policy_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_policy_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.ecs_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_lifecycle_policy.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.aws_ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_access_key.deploy_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_group.developers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.deny_secrets_devops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_group_policy_attachment.power_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.deny_secrets_devops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.deploy_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dynamodb_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.execute_command_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_execution_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecsTaskExecutionRole_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_dynamodb_rw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_execute_command_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.deploy_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.deploy_ec2_ecr_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.deploy_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_security_group.nsg_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.nsg_task_egress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nsg_task_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy.ec2_ecr_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.power_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.dynamodb_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_tasks_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.generic_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_network_interface.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interface) | data source |
| [aws_secretsmanager_secret.devops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_public_dns_zones"></a> [public\_dns\_zones](#input\_public\_dns\_zones) | Route53 Hosted Zone | `map(any)` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name. | `string` | `"ur"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources. Default Milan | `string` | `"eu-south-1"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability zones | `list(string)` | <pre>[<br>  "eu-south-1a",<br>  "eu-south-1b",<br>  "eu-south-1c"<br>]</pre> | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Container port | `number` | `8000` | no |
| <a name="input_ecr_keep_nr_images"></a> [ecr\_keep\_nr\_images](#input\_ecr\_keep\_nr\_images) | Number of images to keep. | `number` | `10` | no |
| <a name="input_ecs_enable_execute_command"></a> [ecs\_enable\_execute\_command](#input\_ecs\_enable\_execute\_command) | Specifies whether to enable Amazon ECS Exec for the tasks within the service. | `bool` | `false` | no |
| <a name="input_ecs_logs_retention_days"></a> [ecs\_logs\_retention\_days](#input\_ecs\_logs\_retention\_days) | Specifies the number of days you want to retain log events in the specified log group. | `number` | `90` | no |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Evnironment short. | `string` | `"d"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | `"Dev"` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of task replica | `number` | `1` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "CreatedBy": "Terraform"<br>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC cidr. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_internal_subnets_cidr"></a> [vpc\_internal\_subnets\_cidr](#input\_vpc\_internal\_subnets\_cidr) | Internal subnets list of cidr. Mainly for private endpoints | `list(string)` | <pre>[<br>  "10.0.201.0/24",<br>  "10.0.202.0/24",<br>  "10.0.203.0/24"<br>]</pre> | no |
| <a name="input_vpc_private_subnets_cidr"></a> [vpc\_private\_subnets\_cidr](#input\_vpc\_private\_subnets\_cidr) | Private subnets list of cidr. | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_vpc_public_subnets_cidr"></a> [vpc\_public\_subnets\_cidr](#input\_vpc\_public\_subnets\_cidr) | Private subnets list of cidr. | `list(string)` | <pre>[<br>  "10.0.101.0/24",<br>  "10.0.102.0/24",<br>  "10.0.103.0/24"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deploy_access_key"></a> [deploy\_access\_key](#output\_deploy\_access\_key) | n/a |
| <a name="output_deploy_access_key_secret"></a> [deploy\_access\_key\_secret](#output\_deploy\_access\_key\_secret) | n/a |
| <a name="output_dynamo_db_table_arn"></a> [dynamo\_db\_table\_arn](#output\_dynamo\_db\_table\_arn) | n/a |
| <a name="output_dynamo_db_table_id"></a> [dynamo\_db\_table\_id](#output\_dynamo\_db\_table\_id) | n/a |
| <a name="output_ecs_definition_task_arn"></a> [ecs\_definition\_task\_arn](#output\_ecs\_definition\_task\_arn) | # ecs |
| <a name="output_ecs_definition_task_revision"></a> [ecs\_definition\_task\_revision](#output\_ecs\_definition\_task\_revision) | n/a |
| <a name="output_invoke_url"></a> [invoke\_url](#output\_invoke\_url) | n/a |
| <a name="output_nlb_hostname"></a> [nlb\_hostname](#output\_nlb\_hostname) | NLB |
| <a name="output_redis_endpoint"></a> [redis\_endpoint](#output\_redis\_endpoint) | redis |
| <a name="output_redis_port"></a> [redis\_port](#output\_redis\_port) | n/a |
