locals {
  dynamodb_table_tokenizer = "Token"
}
module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = local.dynamodb_table_tokenizer
  hash_key  = "PK"
  range_key = "SK"

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
      name            = "gsi_token"
      hash_key        = "token"
      projection_type = "ALL"
    }
  ]


  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_alias.dynamo_db.target_key_arn

  /* TODO --> add replication region in production only.
  replica_regions = [{
    region_name = "eu-central-1"
    kms_key_arn = aws_kms_alias.dynamo_db.target_key_arn
  }]
  */

  tags = { Name = local.dynamodb_table_tokenizer }
}