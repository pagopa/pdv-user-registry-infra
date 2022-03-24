resource "aws_kms_key" "dynamo_db" {
  description              = "Kms dynamo db encryption key."
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  tags = { Name = format("%s-dynamo-table-key", local.project) }
}

resource "aws_kms_alias" "dynamo_db" {
  name          = format("alias/%s-dynamo-table", local.project)
  target_key_id = aws_kms_key.dynamo_db.id
}

# TODO: set a replication region at least for production.
#       set the provisioned capacity.
locals {
  dynamodb_table_name = format("%s-table", local.project)
}
module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = local.dynamodb_table_name
  hash_key  = "id"
  range_key = "CF"

  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "CF"
      type = "S"
    },
  ]

  /*
  global_secondary_indexes = [
    {
      name               = "TitleIndex"
      hash_key           = "title"
      range_key          = "fiscalcode"
      projection_type    = "INCLUDE"
      non_key_attributes = ["id"]
    }
  ]
  */

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_alias.dynamo_db.target_key_arn

  tags = { Name = local.dynamodb_table_name }
}