resource "aws_cloudhsm_v2_cluster" "main" {
  count      = var.create_cloudhsm ? 1 : 0
  hsm_type   = "hsm1.medium"
  subnet_ids = module.vpc.private_subnets

  tags = { "Name" : format("%s-cloudhsm", local.project) }
}

resource "aws_cloudhsm_v2_hsm" "hsm1" {
  count      = var.create_cloudhsm ? 1 : 0
  subnet_id  = module.vpc.private_subnets[0]
  cluster_id = aws_cloudhsm_v2_cluster.main[0].id
}