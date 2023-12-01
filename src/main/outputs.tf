output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

## ecs
output "ecs_task_definition_person_arn" {
  value = data.aws_ecs_task_definition.person.arn
}

output "ecs_task_definition_person_revision" {
  value = data.aws_ecs_task_definition.person.revision
}

output "publish_dokcer_image_x-ray" {
  value = <<EOF
	    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
	    docker pull ${var.x_ray_daemon_image_uri}@${var.x_ray_daemon_image_sha} --platform=linux/amd64
      docker tag ${var.x_ray_daemon_image_uri}@${var.x_ray_daemon_image_sha} ${aws_ecr_repository.main[2].repository_url}:${var.x_ray_daemon_image_version}
	    docker push ${aws_ecr_repository.main[2].repository_url}:${var.x_ray_daemon_image_version}
	    EOF
}

## dynamodb
output "dynamodb_table_person_arn" {
  value = module.dynamodb_table_person.dynamodb_table_arn
}
output "dynamodb_table_person_id" {
  value = module.dynamodb_table_person.dynamodb_table_id
}

# Dns
output "public_dns_zone_name" {
  value = module.dn_zone.route53_zone_name
}

output "public_dns_servers" {
  value = module.dn_zone.route53_zone_name_servers
}

# NLB
output "nlb_hostname" {
  value = module.nlb.lb_dns_name
}

# API Gateway

output "api_gateway_endpoint" {
  value = var.apigw_custom_domain_create ? format("https://%s", aws_api_gateway_domain_name.main[0].domain_name) : ""
}

output "openapi_endpoint" {
  value = var.apigw_custom_domain_create ? format("https://%s/docs/%s/%s",
    aws_api_gateway_domain_name.main[0].domain_name,
    aws_s3_bucket.openapidocs.id,
  aws_s3_object.openapi_user_registry.key, ) : ""
}

# cloud hsm
output "cloudhsm_cluster_id" {
  value = try(aws_cloudhsm_v2_cluster.main[0].id, null)
}

output "cloudhsm_cluster_certificates" {
  value     = try(aws_cloudhsm_v2_cluster.main[0].cluster_certificates, null)
  sensitive = true
}

/*  # todo ... wait for confirmation we need cloudhsm.
output "cloudhsm_hsm_id" {
  value = try(aws_cloudhsm_v2_hsm.hsm.*.hsm_id, null)
}

output "clouthsm_hsm_eni_ip" {
  value = try(data.aws_network_interface.hsm[0].private_ip, null)
}
*/

# sentinel
output "sentinel_role_arn" {
  value = try(module.sentinel[0].sentinel_role_arn, null)
}

output "sentinel_queue_url" {
  value = try(module.sentinel[0].sentinel_queue_url, null)
}

output "user_registry_api_ids" {
  value = local.user_registry_api_ids
}

output "github_ecs_deploy_role_arn" {
  value = aws_iam_role.githubecsdeploy.arn
}