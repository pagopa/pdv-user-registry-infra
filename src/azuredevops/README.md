## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.63.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | = 0.1.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.63.0 |
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | = 0.1.8 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iac_deploy"></a> [iac\_deploy](#module\_iac\_deploy) | git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v2.0.5 |  |

## Resources

| Name | Type |
|------|------|
| [azuredevops_project.this](https://registry.terraform.io/providers/microsoft/azuredevops/0.1.8/docs/resources/project) | resource |
| [azuredevops_project_features.features](https://registry.terraform.io/providers/microsoft/azuredevops/0.1.8/docs/resources/project_features) | resource |
| [azuredevops_serviceendpoint_aws.serviceendpoint](https://registry.terraform.io/providers/microsoft/azuredevops/0.1.8/docs/resources/serviceendpoint_aws) | resource |
| [azuredevops_serviceendpoint_github.github_pr](https://registry.terraform.io/providers/microsoft/azuredevops/0.1.8/docs/resources/serviceendpoint_github) | resource |
| [azuredevops_serviceendpoint_github.github_ro](https://registry.terraform.io/providers/microsoft/azuredevops/0.1.8/docs/resources/serviceendpoint_github) | resource |
| [aws_secretsmanager_secret.devops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.devops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iac"></a> [iac](#input\_iac) | n/a | `map` | <pre>{<br>  "pipeline": {<br>    "enable_code_review": true,<br>    "enable_deploy": true<br>  },<br>  "repository": {<br>    "branch_name": "refs/heads/main",<br>    "name": "pagopa.gov.it-infrastructure",<br>    "organization": "pagopa",<br>    "pipelines_path": "pipelines",<br>    "yml_prefix_name": null<br>  }<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS default region | `string` | `"eu-south-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project"></a> [project](#output\_project) | n/a |
