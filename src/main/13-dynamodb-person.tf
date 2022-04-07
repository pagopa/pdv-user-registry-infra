locals {
  # Person
  dynamodb_table_person    = "Person"
  dynamodb_gsi_person_name = "gsi_namespaced_id"
}

# Table Person
module "dynamodb_table_person" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name                           = local.dynamodb_table_person
  hash_key                       = "PK"
  range_key                      = "SK"
  stream_enabled                 = var.dynamodb_region_replication_enable ? true : false
  point_in_time_recovery_enabled = var.dynamodb_point_in_time_recovery_enabled

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
      name = "namespacedId"
      type = "S"
    },
    /*
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

  global_secondary_indexes = [
    {
      name            = local.dynamodb_gsi_person_name
      hash_key        = "namespacedId"
      projection_type = "ALL"
    }
  ]


  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_alias.dynamo_db.target_key_arn

  replica_regions = var.dynamodb_region_replication_enable ? [{
    region_name = "eu-central-1"
    kms_key_arn = aws_kms_alias.dynamo_db_replica[0].target_key_arn
  }] : []


  tags = { Name = local.dynamodb_table_person }
}