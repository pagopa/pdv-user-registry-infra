module "vpc" {
  source                = "terraform-aws-modules/vpc/aws"
  version               = "5.17.0"
  name                  = format("%s-vpc", local.project)
  cidr                  = var.vpc_cidr
  azs                   = var.azs
  private_subnets       = var.vpc_private_subnets_cidr
  private_subnet_suffix = "private"
  public_subnets        = var.vpc_public_subnets_cidr
  public_subnet_suffix  = "public"
  intra_subnets         = var.vpc_internal_subnets_cidr
  enable_nat_gateway    = var.enable_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

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

data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"

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

  tags = { Name = format("%s_vpc_tls_sg", local.project) }
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.17.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags            = { Name = "s3-vpc-endpoint" }
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]
      tags               = { Name = "logs-endpoint" }
    },
    xray = {
      service             = "xray"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]
      tags               = { Name = "xray-endpoint" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]

      tags = { Name = "ecr.api-endpoint" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]
      tags               = { Name = "ecr.dkr-endpoint" }
    },

    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      # policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      tags = { Name = "dynamodb-vpc-endpoint" }
    },
    /*
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

}

## VPC Peering
resource "aws_vpc_peering_connection" "owner" {
  count         = var.vpc_peering != null ? 1 : 0
  vpc_id        = module.vpc.vpc_id
  peer_vpc_id   = var.vpc_peering.peer_vpc_id
  peer_owner_id = var.vpc_peering.peer_owner_id

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = format("peer-to-%s", var.vpc_peering.peer_profile)
  }
}

resource "null_resource" "vpc_peering" {
  count = var.vpc_peering != null ? 1 : 0
  triggers = {
    cluster_instance_ids = aws_vpc_peering_connection.owner[0].id
  }

  provisioner "local-exec" {
    command = "echo \"WARNING: Peering connection need to be accepted \" "
  }
}


output "vpc_peering_id" {
  value = try(aws_vpc_peering_connection.owner[0].id, null)
}
output "vpc_peering_status" {
  value = try(aws_vpc_peering_connection.owner[0].accept_status, null)
}

data "aws_route_tables" "owner" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_route" "owner" {
  count                     = var.vpc_peering != null ? length(data.aws_route_tables.owner.ids) : 0
  route_table_id            = data.aws_route_tables.owner.ids[count.index]
  destination_cidr_block    = var.vpc_peering.accepter_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.owner[0].id
}