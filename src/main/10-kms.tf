resource "aws_kms_key" "dynamo_db" {
  description              = "Kms dynamo db encryption key."
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  tags = { Name = format("%s-dynamo-table-key", local.project) }
}

resource "aws_kms_alias" "dynamo_db" {
  name          = format("alias/%s-dynamo-table", local.project)
  target_key_id = aws_kms_key.dynamo_db.id
}