resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "MS-User-Registry"

  dashboard_body = templatefile("${path.module}/dashboards/main.tpl.json",
    {
      aws_region                = var.aws_region
      apigateway_api_name       = aws_api_gateway_rest_api.user_registry.name
      nlb_arn_suffix            = module.nlb.lb_arn_suffix
      nlb_target_arn_suffix_ur  = module.nlb.target_group_arn_suffixes[1]
      ecs_user_registry_service = aws_ecs_service.user_registry.name
      ecs_cluster_name          = aws_ecs_cluster.ecs_cluster.name
      ecs_person_service        = aws_ecs_service.person.name
      waf_web_acl               = aws_wafv2_web_acl.main.name
      user_registry_api_ids     = local.user_registry_api_ids

    }
  )
}