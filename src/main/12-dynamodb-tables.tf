locals {
  dynamodb_table_tokenizer = "Token"
  # global secondary index
  dynamo_gsi_tokenizer_name = "gsi_token"
}
module "dynamodb_table_tokenizer" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = local.dynamodb_table_tokenizer
  hash_key       = "PK"
  range_key      = "SK"
  stream_enabled = var.env_short == "p" ? true : false

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
      name            = local.dynamo_gsi_tokenizer_name
      hash_key        = "token"
      projection_type = "ALL"
    }
  ]


  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_alias.dynamo_db.target_key_arn

  replica_regions = var.env_short == "p" ? [{
    region_name = "eu-central-1"
    kms_key_arn = aws_kms_alias.dynamo_db_replica[0].target_key_arn
  }] : []


  tags = { Name = local.dynamodb_table_tokenizer }
}