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


resource "aws_security_group_rule" "task_hsm" {
  count       = var.create_cloudhsm ? 1 : 0
  description = "Only allow connections from fargate tasks nsg ${count.index}"
  type        = "ingress"
  from_port   = 2223
  to_port     = 2225
  protocol    = "tcp"

  # security group assigned to fargate tasks.
  source_security_group_id = aws_security_group.nsg_task.id

  security_group_id = aws_cloudhsm_v2_cluster.main[0].security_group_id
}


data "aws_network_interface" "hsm" {
  count = var.create_cloudhsm ? 1 : 0
  id    = aws_cloudhsm_v2_hsm.hsm1[0].hsm_eni_id
}