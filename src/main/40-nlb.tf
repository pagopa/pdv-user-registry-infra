resource "aws_security_group" "nsg_task" {
  name        = format("%s-task-nlb", local.project)
  description = "Limit connections from internal resources while allowing ${local.project}-task to connect to all external resources"
  vpc_id      = module.vpc.vpc_id

  tags = { Name = format("%s-task-nlb", local.project) }
}

# Rules for the TASK (Targets the LB's IPs)
locals {
  # list of container port in use.
  container_ports = [
    var.container_port_tokenizer,
    var.container_port_person,
    var.container_port_user_registry,
    var.container_port_poc,
  ]
}
resource "aws_security_group_rule" "nsg_task_ingress_rule" {
  count       = length(local.container_ports)
  description = "Only allow connections from the NLB ${count.index}"
  type        = "ingress"
  from_port   = local.container_ports[count.index]
  to_port     = local.container_ports[count.index]
  protocol    = "tcp"
  cidr_blocks = formatlist(
    "%s/32",
    flatten(data.aws_network_interface.nlb.*.private_ips),
  )

  security_group_id = aws_security_group.nsg_task.id
}

resource "aws_security_group_rule" "nsg_task_egress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_task.id
}

# lookup the ENIs associated with the NLB
data "aws_network_interface" "nlb" {
  count = length(module.vpc.private_subnets)

  filter {
    name   = "description"
    values = ["ELB ${module.nlb.lb_arn_suffix}"]
  }

  filter {
    name   = "subnet-id"
    values = [element(module.vpc.private_subnets, count.index)]
  }
}

module "nlb" {
  source = "terraform-aws-modules/alb/aws"

  name = format("%s-nlb", local.project)

  load_balancer_type = "network"

  vpc_id                           = module.vpc.vpc_id
  subnets                          = module.vpc.private_subnets
  enable_cross_zone_load_balancing = "true"

  internal = true

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = var.container_port_person
      protocol           = "TCP"
      target_group_index = 1
    },
    {
      port               = var.container_port_user_registry
      protocol           = "TCP"
      target_group_index = 2
    },
  ]


  target_groups = [
    {
      # service tokenizer
      name             = format("%s-tokenizer", local.project)
      backend_protocol = "TCP"
      backend_port     = 80
      #port        = 80
      target_type = "ip"
      #preserve_client_ip = true
      deregistration_delay = 30
      vpc_id               = module.vpc.vpc_id

      health_check = {
        enabled = true

        healthy_threshold   = 3
        interval            = 30
        timeout             = 6
        unhealthy_threshold = 3
        matcher             = "200-399"
        path                = "/actuator/health"
      }
    },
    # service person
    {
      name             = format("%s-person", local.project)
      backend_protocol = "TCP"
      backend_port     = var.container_port_person
      #port        = 80
      target_type = "ip"
      #preserve_client_ip = true
      deregistration_delay = 30
      vpc_id               = module.vpc.vpc_id

      health_check = {
        enabled = true

        healthy_threshold   = 3
        interval            = 30
        timeout             = 6
        unhealthy_threshold = 3
        matcher             = "200-399"
        path                = "/actuator/health"
      }
    },
    # Service user registry.
    {
      name             = format("%s-user-registry", local.project)
      backend_protocol = "TCP"
      backend_port     = var.container_port_user_registry
      #port        = 80
      target_type = "ip"
      #preserve_client_ip = true
      deregistration_delay = 30
      vpc_id               = module.vpc.vpc_id

      health_check = {
        enabled = true

        healthy_threshold   = 3
        interval            = 30
        timeout             = 6
        unhealthy_threshold = 3
        matcher             = "200-399"
        path                = "/actuator/health"
      }
    },

    # Service poc
    {
      name             = format("%s-poc", local.project)
      backend_protocol = "TCP"
      backend_port     = var.container_port_poc
      #port        = 80
      target_type = "ip"
      #preserve_client_ip = true
      deregistration_delay = 30
      vpc_id               = module.vpc.vpc_id

      health_check = {
        enabled = true

        healthy_threshold   = 3
        interval            = 30
        timeout             = 6
        unhealthy_threshold = 3
        matcher             = "200-399"
        path                = "/"
      }
    },
  ]

  tags = { Name : format("%s-nlb", local.project) }
}