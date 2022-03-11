module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = format("%s-table", local.project)
  hash_key  = "id"
  range_key = "fiscalcode"

  attributes = [
    {
      name = "id"
      type = "N"
    },
    {
      name = "fiscalcode"
      type = "S"
    }
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

  server_side_encryption_enabled = true

  tags = var.tags
}