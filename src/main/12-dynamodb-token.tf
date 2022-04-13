locals {
  # Token
  dynamodb_table_token  = "Token"
  dynamo_gsi_token_name = keys(var.table_token_autoscling_indexes)[0]
}

# Table Token
module "dynamodb_table_token" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name                           = local.dynamodb_table_token
  hash_key                       = "PK"
  range_key                      = "SK"
  stream_enabled                 = var.env_short == "p" ? true : false
  point_in_time_recovery_enabled = var.dynamodb_point_in_time_recovery_enabled
  billing_mode                   = "PROVISIONED"
  autoscaling_enabled            = true
  read_capacity                  = var.table_token_read_capacity
  write_capacity                 = var.table_token_write_capacity

  attributes = [
    {
      name = "PK"
      type = "S"
    },
    {
      name = "SK"
      type = "S"
    },
    {
      name = "token"
      type = "S"
    },
  ]

  global_secondary_indexes = [
    {
      name            = local.dynamo_gsi_token_name
      hash_key        = "token"
      projection_type = "ALL"
      write_capacity  = var.table_token_autoscling_indexes[local.dynamo_gsi_token_name]["write_min_capacity"]
      read_capacity   = var.table_token_autoscling_indexes[local.dynamo_gsi_token_name]["read_min_capacity"]
    }
  ]


  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_alias.dynamo_db.target_key_arn

  autoscaling_read = var.table_token_autoscaling_read

  autoscaling_write = var.table_token_autoscaling_write

  autoscaling_indexes = var.table_token_autoscling_indexes

  replica_regions = var.dynamodb_region_replication_enable ? [{
    region_name = "eu-central-1"
    kms_key_arn = aws_kms_alias.dynamo_db_replica[0].target_key_arn
  }] : []


  tags = { Name = local.dynamodb_table_token }
}