module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = format("%s-vpc", local.project)
  cidr               = var.vpc_cidr
  azs                = var.azs
  private_subnets    = var.vpc_private_subnets_cidr
  public_subnets     = var.vpc_public_subnets_cidr
  intra_subnets      = var.vpc_internal_subnets_cidr
  enable_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({
    Name = format("%s-vpc", local.project) },
  var.tags)
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "vpc_tls" {
  name_prefix = format("%s_vpc_tls_sg", local.project)
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = merge({ Name = format("%s_vpc_tls_sg", local.project) }, var.tags)
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags            = merge({ Name = "s3-vpc-endpoint" }, var.tags)
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]
      tags               = merge({ Name = "logs-endpoint" }, var.tags)
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]

      tags = merge({ Name = "ecr.api-endpoint" }, var.tags)
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]
      tags               = merge({ Name = "ecr.dkr-endpoint" }, var.tags)
    },
    /*
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      tags            = { Name = "dynamodb-vpc-endpoint" }
    },
    
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = merge({ Name = "ecs-endpoint" }, var.tags)
    },
    ecs_telemetry = {
      service             = "ecs-telemetry"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = merge({ Name = "ecs-telemetry-endpoint" }, var.tags)
    },    
    kms = {
      service             = "kms"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_tls.id]
      tags                = merge({ Name = "kms-endpoint" }, var.tags)
    },
    */
  }

  tags = var.tags
}