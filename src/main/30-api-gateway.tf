locals {
  apigw_name  = format("%s-apigw-vpc-lik", local.project)
  webacl_name = format("%s-webacl", local.project)
}

resource "aws_api_gateway_vpc_link" "apigw" {
  name        = local.apigw_name
  description = "allows public API Gateway for ${local.apigw_name} to talk to private NLB"
  target_arns = [module.nlb.lb_arn]

  tags = { Name = local.apigw_name }

}

## Firewall regional web acl  
resource "aws_wafv2_web_acl" "main" {
  name        = format("%s-webacl", local.project)
  description = "Api gateway WAF."
  scope       = "REGIONAL"

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.webacl_name
    sampled_requests_enabled   = true
  }
  default_action {
    allow {}
  }

  rule {
    name     = "IpReputationList"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = local.webacl_name
      sampled_requests_enabled   = false
    }
  }


  rule {
    name     = "CommonRuleSet"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = local.webacl_name
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "KnownBadInputsRuleSet"
    priority = 3

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = local.webacl_name
      sampled_requests_enabled   = false
    }
  }

  tags = { Name = format("%s-webacl", local.project) }
}

## API Gateway cloud watch logs
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.apigw.arn
}

resource "aws_iam_role" "apigw" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.apigw.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}