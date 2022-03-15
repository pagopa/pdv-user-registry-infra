module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = format("%s-table", local.project)
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

  server_side_encryption_enabled = true

  tags = { Name = format("%s-table", local.project) }
}