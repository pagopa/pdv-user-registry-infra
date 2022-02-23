module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = format("%s-%s-vpc", local.project, var.aws_region)
  cidr               = var.vpc_cidr
  azs                = var.azs
  private_subnets    = var.vpc_private_subnets_cidr
  public_subnets     = var.vpc_public_subnets_cidr
  enable_nat_gateway = true
  tags               = var.tags
}