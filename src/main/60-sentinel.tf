# this module set up all resources needed to create resources to send logs to azure sentinel

locals {
  trail_name        = format("%s-sentinel-trail", local.project)
  sentinel_policies = ["AmazonSQSReadOnlyAccess", "AmazonS3ReadOnlyAccess", "PagoPaAllowECSKMS"]
  queue_name        = format("%s-sentinel-queue", local.project)
}

resource "aws_iam_role" "sentinel" {
  count = var.enable_sentinel_logs ? 1 : 0
  name  = "MicrosoftSentinelRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        "Principal" : {
          "AWS" : "${var.sentinel_servcie_account_id}"
        },
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : "${var.sentinel_workspace_id}"
          }
        }
      }
    ]
  })
}

data "aws_iam_policy" "sentinel" {
  count = var.enable_sentinel_logs ? length(local.sentinel_policies) : 0
  name  = local.sentinel_policies[count.index]
}

resource "aws_iam_role_policy_attachment" "sentinel" {
  count      = var.enable_sentinel_logs ? length(local.sentinel_policies) : 0
  role       = aws_iam_role.sentinel[0].name
  policy_arn = data.aws_iam_policy.sentinel[count.index].arn
}


# SQS queue
resource "aws_sqs_queue" "sentinel" {
  count = var.enable_sentinel_logs ? 1 : 0
  name  = local.queue_name

  policy = templatefile("./iam_policies/allow-sqs-s3.tpl.json",
    {
      queue_name = local.queue_name
      bucket_arn = aws_s3_bucket.sentinel_logs[0].arn
  })
}


# S3 bucket
resource "aws_s3_bucket" "sentinel_logs" {
  count  = var.enable_sentinel_logs ? 1 : 0
  bucket = format("%ssentinellogs", replace(local.project, "-", ""))
  lifecycle {
    # prevent_destroy = true
  }
}

## Set the bucket ACL private.
resource "aws_s3_bucket_acl" "sentinel_logs" {
  count  = var.enable_sentinel_logs ? 1 : 0
  bucket = aws_s3_bucket.sentinel_logs[0].id
  acl    = "private"
}

## Block public access.
resource "aws_s3_bucket_public_access_block" "sentinel_logs" {
  count                   = var.enable_sentinel_logs ? 1 : 0
  bucket                  = aws_s3_bucket.sentinel_logs[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## S3 policy which allow cloud trail to write logs.

resource "aws_s3_bucket_policy" "sentinel_logs" {
  count  = var.enable_sentinel_logs ? 1 : 0
  bucket = aws_s3_bucket.sentinel_logs[0].id

  policy = templatefile("./iam_policies/allow-s3-cloudtrail.tpl.json", {
    account_id  = data.aws_caller_identity.current.account_id
    bucket_name = aws_s3_bucket.sentinel_logs[0].id
  })
}

## s3 lifecycle rule to delete old files.
resource "aws_s3_bucket_lifecycle_configuration" "sentinel" {
  count  = var.enable_sentinel_logs ? 1 : 0
  bucket = aws_s3_bucket.sentinel_logs[0].bucket

  rule {
    expiration {
      days = 7
    }
    id = "clean"

    noncurrent_version_expiration {
      newer_noncurrent_versions = 1
      noncurrent_days           = 1
    }

    status = "Enabled"
  }

}

## s3 notification to SQS to notify new logs have been stored.
resource "aws_s3_bucket_notification" "sentinel" {
  count  = var.enable_sentinel_logs ? 1 : 0
  bucket = aws_s3_bucket.sentinel_logs[0].id

  queue {
    queue_arn = aws_sqs_queue.sentinel[0].arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# KMS key cloudtrail ueses to encrypt logs.

resource "aws_kms_key" "sentinel_logs" {
  count                    = var.enable_sentinel_logs ? 1 : 0
  description              = "Kms key to entrypt cloudtrail logs."
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  policy = templatefile("./iam_policies/allow-kms-cloudtrail.tpl.json", {
    account_id = data.aws_caller_identity.current.account_id
    trail_name = local.trail_name
    aws_region = var.aws_region
  })

  tags = { Name = format("%s-sentinel-logs-key", local.project) }
}


resource "aws_kms_alias" "sentinel_logs" {
  count         = var.enable_sentinel_logs ? 1 : 0
  name          = format("alias/%s-sentinel-logs", local.project)
  target_key_id = aws_kms_key.sentinel_logs[0].id
}

# Trail to collect all managements events.
resource "aws_cloudtrail" "sentinel" {
  count                         = var.enable_sentinel_logs ? 1 : 0
  name                          = local.trail_name
  s3_bucket_name                = aws_s3_bucket.sentinel_logs[0].id
  include_global_service_events = true
  kms_key_id                    = aws_kms_alias.sentinel_logs[0].arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [
    aws_s3_bucket_policy.sentinel_logs,
    aws_kms_key.sentinel_logs
  ]
}