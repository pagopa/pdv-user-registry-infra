# TODO: try with sops and see if it's more affordable.
data "aws_secretsmanager_secret" "devops" {
  name = "devops"
}

data "aws_secretsmanager_secret_version" "devops" {
  secret_id = data.aws_secretsmanager_secret.devops.id
}
