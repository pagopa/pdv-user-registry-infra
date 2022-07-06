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