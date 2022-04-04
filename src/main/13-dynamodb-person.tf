locals {
  # Person
  dynamodb_table_person  = "Person"
  dynamo_gsi_person_name = "gsi_namespaced_id"
}

# Table Person
module "dynamodb_table_person" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = local.dynamodb_table_person
  hash_key       = "PK"
  range_key      = "SK"
  stream_enabled = var.dynamodb_region_replication_enable ? true : false

  attributes = [
    {
      name = "PK"
      type = "S"
    },
    {
      name = "SK"
      type = "S"
    },
    /* * all attributes must be indexed. Unused attributes: ["familyName" "email" "givenName" "birthDate" "workContacts"] 
    {
      name = "givenName"
      type = "S"
    },
    {
      name = "familyName"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    },
    {
      name = "birthDate"
      type = "S"
    },
    {
      name = "workContacts"
      type = "S"
    },
    */
  ]

  /*

  global_secondary_indexes = [
    {
      name            = local.dynamo_gsi_person_name
      hash_key        = "token"
      projection_type = "ALL"
    }
  ]
  */

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_alias.dynamo_db.target_key_arn

  replica_regions = var.dynamodb_region_replication_enable ? [{
    region_name = "eu-central-1"
    kms_key_arn = aws_kms_alias.dynamo_db_replica[0].target_key_arn
  }] : []


  tags = { Name = local.dynamodb_table_person }
}