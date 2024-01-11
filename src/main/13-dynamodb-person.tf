locals {
  # Person
  dynamodb_table_person    = "Person"
  dynamodb_gsi_person_name = "gsi_namespaced_id"
}

# Table Person
module "dynamodb_table_person" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table.git?ref=03b38ee3c52250c7d606f6a21e04624a41be52f7"

  name                           = local.dynamodb_table_person
  hash_key                       = "PK"
  range_key                      = "SK"
  stream_enabled                 = var.dynamodb_region_replication_enable
  point_in_time_recovery_enabled = var.dynamodb_point_in_time_recovery_enabled
  billing_mode                   = "PAY_PER_REQUEST"
  stream_view_type               = var.dynamodb_region_replication_enable ? "NEW_AND_OLD_IMAGES" : null


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
  ]

  global_secondary_indexes = [
    {
      name            = local.dynamodb_gsi_person_name
      hash_key        = "namespacedId"
      projection_type = "KEYS_ONLY"
      # write_capacity  = var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["write_min_capacity"]
      # read_capacity   = var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["read_min_capacity"]
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
