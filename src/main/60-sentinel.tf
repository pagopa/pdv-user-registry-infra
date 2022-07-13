module "sentinel" {
  count  = var.enable_sentinel_logs ? 1 : 0
  source = "git::https://github.com/pagopa/terraform-aws-sentinel.git?ref=v1.0.0"

  account_id            = data.aws_caller_identity.current.account_id
  queue_name            = format("%s-sentinel-queue", local.project)
  trail_name            = format("%s-sentinel-trail", local.project)
  sentinel_bucket_name  = format("%s-sentinel-logs", local.project)
  expiration_days       = 3
  sentinel_workspace_id = var.sentinel_workspace_id

}