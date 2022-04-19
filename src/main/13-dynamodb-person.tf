locals {
  # Person
  dynamodb_table_person    = "Person"
  dynamodb_gsi_person_name = keys(var.table_person_autoscling_indexes)[0]
}

# Table Person
module "dynamodb_table_person_eu_south_1" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name                           = local.dynamodb_table_person
  hash_key                       = "PK"
  range_key                      = "SK"
  point_in_time_recovery_enabled = var.dynamodb_point_in_time_recovery_enabled
  billing_mode                   = "PROVISIONED"
  autoscaling_enabled            = true
  read_capacity                  = var.table_person_read_capacity
  write_capacity                 = var.table_person_write_capacity

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
      projection_type = "ALL"
      write_capacity  = var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["write_min_capacity"]
      read_capacity   = var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["read_min_capacity"]
    }
  ]


  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_alias.dynamo_db.target_key_arn

  autoscaling_read    = var.table_person_autoscaling_read
  autoscaling_write   = var.table_person_autoscaling_write
  autoscaling_indexes = var.table_person_autoscling_indexes

  stream_enabled   = var.dynamodb_region_replication_enable ? true : false
  stream_view_type = var.dynamodb_region_replication_enable ? "NEW_AND_OLD_IMAGES" : null

  /*
  replica_regions = var.dynamodb_region_replication_enable ? [{
    region_name = "eu-central-1"
    kms_key_arn = aws_kms_alias.dynamo_db_replica[0].target_key_arn
  }] : []

  */

  tags = { Name = local.dynamodb_table_person }
}

# Table Person (replica)
module "dynamodb_table_person_eu_central_1" {
  source = "terraform-aws-modules/dynamodb-table/aws"
  count  = var.dynamodb_region_replication_enable ? 1 : 0

  providers = {
    aws = aws.eu-central-1
  }

  name                           = local.dynamodb_table_person
  hash_key                       = "PK"
  range_key                      = "SK"
  point_in_time_recovery_enabled = var.dynamodb_point_in_time_recovery_enabled
  billing_mode                   = "PROVISIONED"
  autoscaling_enabled            = true
  read_capacity                  = var.table_person_read_capacity
  write_capacity                 = var.table_person_write_capacity

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
      projection_type = "ALL"
      write_capacity  = var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["write_min_capacity"]
      read_capacity   = var.table_person_autoscling_indexes[local.dynamodb_gsi_person_name]["read_min_capacity"]
    }
  ]


  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_alias.dynamo_db.target_key_arn

  autoscaling_read    = var.table_person_autoscaling_read
  autoscaling_write   = var.table_person_autoscaling_write
  autoscaling_indexes = var.table_person_autoscling_indexes

  stream_enabled   = var.dynamodb_region_replication_enable ? true : false
  stream_view_type = var.dynamodb_region_replication_enable ? "NEW_AND_OLD_IMAGES" : null

  /*
  replica_regions = var.dynamodb_region_replication_enable ? [{
    region_name = "eu-central-1"
    kms_key_arn = aws_kms_alias.dynamo_db_replica[0].target_key_arn
  }] : []

  */

  tags = { Name = local.dynamodb_table_person }
}