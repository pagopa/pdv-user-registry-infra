# this module set up all resources needed to create resources to send logs to azure sentinel
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


# SQS queue
resource "aws_sqs_queue" "terraform_queue" {
  count = var.enable_sentinel_logs ? 1 : 0
  name  = format("%s-sentinel-queue", local.project)
}


# S3 bucket
resource "aws_s3_bucket" "sentinel_logs" {
  count  = var.enable_sentinel_logs ? 1 : 0
  bucket = format("%ssentinellogs", replace(local.project, "-", ""))
  lifecycle {
    # prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "sentinel_logs" {
  count  = var.enable_sentinel_logs ? 1 : 0
  bucket = aws_s3_bucket.sentinel_logs[0].id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "sentinel_logs" {
  count                   = var.enable_sentinel_logs ? 1 : 0
  bucket                  = aws_s3_bucket.sentinel_logs[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "sentinel_logs" {
  count  = var.enable_sentinel_logs ? 1 : 0
  bucket = aws_s3_bucket.sentinel_logs[0].id
  policy = templatefile("./iam_policies/allow-s3-cloudtrail.tpl.json", {
    account_id  = data.aws_caller_identity.current.account_id
    bucket_name = aws_s3_bucket.sentinel_logs[0].id
    trail_arn   = aws_cloudtrail.sentinel[0].arn
  })
}

resource "aws_kms_key" "sentinel_logs" {
  count                    = var.enable_sentinel_logs ? 1 : 0
  description              = "Kms key to entrypt cloudtrail logs."
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  tags = { Name = format("%s-sentinel-logs-key", local.project) }
}

/*
resource "aws_kms_alias" "sentinel_logs" {
  count         = var.enable_sentinel_logs ? 1 : 0
  name          = format("alias/%s-sentinel-logs", local.project)
  target_key_id = aws_kms_key.dynamo_db.id
}
*/

resource "aws_cloudtrail" "sentinel" {
  count          = var.enable_sentinel_logs ? 1 : 0
  name           = "%s-sentinel-trail"
  s3_bucket_name = aws_s3_bucket.sentinel_logs[0].id
  # s3_key_prefix                 = "sentinel"
  include_global_service_events = true
  kms_key_id                    = aws_kms_key.sentinel_logs[0].id

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    /*
    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
    */
  }
}