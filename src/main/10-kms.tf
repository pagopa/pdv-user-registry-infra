resource "aws_kms_key" "dynamo_db" {
  description              = "Kms dynamo db encryption key."
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  tags = { Name = format("%s-dynamo-table-key", local.project) }
}

resource "aws_kms_alias" "dynamo_db" {
  name          = format("alias/%s-dynamo-table", local.project)
  target_key_id = aws_kms_key.dynamo_db.id
}

resource "aws_kms_key" "dynamo_db_replica" {
  provider                 = aws.eu-central-1
  count                    = var.env_short == "p" ? 1 : 0
  description              = "Kms dynamo db encryption key."
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  tags = { Name = format("%s-dynamo-table-key", local.project) }
}

resource "aws_kms_alias" "dynamo_db_replica" {
  provider      = aws.eu-central-1
  count         = var.env_short == "p" ? 1 : 0
  name          = format("alias/%s-dynamo-table", local.project)
  target_key_id = aws_kms_key.dynamo_db_replica[0].id
}