resource "aws_cloudhsm_v2_cluster" "main" {
  count      = var.create_cloudhsm ? 1 : 0
  hsm_type   = "hsm1.medium"
  subnet_ids = module.vpc.private_subnets

  tags = { "Name" : format("%s-cloudhsm", local.project) }
}