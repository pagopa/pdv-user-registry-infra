resource "aws_cloudhsm_v2_cluster" "main" {
  count      = var.create_cloudhsm ? 1 : 0
  hsm_type   = "hsm1.medium"
  subnet_ids = module.vpc.private_subnets

  tags = { "Name" : format("%s-cloudhsm", local.project) }
}

## Note: at least two cloudhsm are requird within the cluster to create a 
## a key store. 
/* #TODO ... wait for activation tests
resource "aws_cloudhsm_v2_hsm" "hsm" {
  count      = var.create_cloudhsm ? 1 : 0
  subnet_id  = module.vpc.private_subnets[count.index]
  cluster_id = aws_cloudhsm_v2_cluster.main[0].id
}

data "aws_network_interface" "hsm" {
  count = var.create_cloudhsm ? 1 : 0
  id    = aws_cloudhsm_v2_hsm.hsm[count.index].hsm_eni_id
}

*/