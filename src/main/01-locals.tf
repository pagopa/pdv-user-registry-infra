locals {
  task_person_name    = format("%s-task-person", local.project)
  service_person_name = format("%s-service-person", local.project)

  task_user_registry_name    = format("%s-task-user-registry", local.project)
  service_user_registry_name = format("%s-service-user-registry", local.project)

  apigw_name  = format("%s-apigw-vpc-lik", local.project)
  webacl_name = format("%s-webacl", local.project)

  api_key_list = { for k in var.user_registry_plans : k.key_name => k }

  additional_keys = flatten([for k in var.user_registry_plans :
    [for a in k.additional_keys :
      {
        "key" : a
        "plan" : k.key_name
    }]
  ])

  list_user_registry_key_to_name = concat(
    [for n in var.user_registry_plans : "'${aws_api_gateway_api_key.main[n.key_name].id}':'${n.key_name}'"],
    [for n in local.additional_keys : "'${aws_api_gateway_api_key.additional[n.key].id}':'${n.plan}'"]
  )

  user_registry_api_ids = merge(
    { for k in keys(local.api_key_list) : k => aws_api_gateway_usage_plan.user_registry[k].id },
    { for k in local.additional_keys : k.key => aws_api_gateway_usage_plan.user_registry[k.plan].id },
  )

  runbook_title = "Runbook"
  runbook_url   = "https://pagopa.atlassian.net/wiki/spaces/usrreg/pages/696615213/Runbook+-+PDV+Troubleshooting"
  runbook_link = format("<a href='%s'>%s</a>",
    local.runbook_url, local.runbook_title
  )

}