resource "aws_cloudwatch_dashboard" "fargate" {
  count          = var.env_short == "p" ? 0 : 1
  dashboard_name = format("%s-fargate", local.project)

  dashboard_body = templatefile("./dashboards/${var.environment}/fargate.tpl.json",
    {
      aws_region                 = var.aws_region,
      service_tokenizer          = aws_ecs_service.tokenizer.name,
      service_person             = aws_ecs_service.person.name,
      cluster_name               = aws_ecs_cluster.ecs_cluster.name,
      nlb_arn_suffix             = module.nlb.lb_arn_suffix,
      target_group_tokenizer_arn = module.nlb.target_group_arn_suffixes[0]
      target_group_person_arn    = module.nlb.target_group_arn_suffixes[1],
  })
}