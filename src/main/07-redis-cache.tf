module "redis_sg" {
  source      = "git::https://github.com/pagopa/terraform-aws-modules.git//security-group?ref=v1.3.4"
  name        = format("%s-redis-sg", local.project)
  description = "Redis security groups"

  vpc_id = module.vpc.vpc_id

  tags = { Name = format("%s-redis-sg", local.project) }

}

## TODO
# 1. inbound rule to allow access on port 6379
# 2. outbound rule all traffic.


module "redis" {
  source = "git::https://github.com/pagopa/terraform-aws-modules.git//elastic-cache-redis?ref=v1.3.3"

  name             = format("%s-redis", local.project)
  redis_clusters   = "2"
  redis_failover   = "true"
  redis_version    = "6.x"
  subnets          = module.vpc.private_subnets
  vpc_id           = module.vpc.vpc_id
  redis_node_type  = "cache.t3.small"
  multi_az_enabled = true

  security_group_ids = [module.redis_sg.id]

  redis_parameters = [{
    name  = "min-replicas-max-lag"
    value = "5"
    }, {
    name  = "min-replicas-to-write"
    value = "1"
    }, {
    name  = "databases"
    value = "3"
  }]

  tags = { Name = format("%s-redis", local.project) }
}