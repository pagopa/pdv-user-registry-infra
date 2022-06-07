## Firewall regional web acl  
resource "aws_wafv2_web_acl" "main" {
  name        = format("%s-webacl", local.project)
  description = "Api gateway WAF."
  scope       = "REGIONAL"

  visibility_config {
    cloudwatch_metrics_enabled = var.web_acl_visibility_config.cloudwatch_metrics_enabled
    metric_name                = local.webacl_name
    sampled_requests_enabled   = var.web_acl_visibility_config.sampled_requests_enabled
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
      cloudwatch_metrics_enabled = var.web_acl_visibility_config.cloudwatch_metrics_enabled
      metric_name                = "IpReputationList"
      sampled_requests_enabled   = var.web_acl_visibility_config.sampled_requests_enabled
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
      cloudwatch_metrics_enabled = var.web_acl_visibility_config.cloudwatch_metrics_enabled
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = var.web_acl_visibility_config.sampled_requests_enabled
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
      cloudwatch_metrics_enabled = var.web_acl_visibility_config.cloudwatch_metrics_enabled
      metric_name                = "KnownBadInputsRuleSet"
      sampled_requests_enabled   = var.web_acl_visibility_config.sampled_requests_enabled
    }
  }

  rule {
    name     = "SQLiRuleSet"
    priority = 4

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.web_acl_visibility_config.cloudwatch_metrics_enabled
      metric_name                = "SQLiRuleSet"
      sampled_requests_enabled   = var.web_acl_visibility_config.sampled_requests_enabled
    }
  }

  tags = { Name = format("%s-webacl", local.project) }
}

## Alarm

module "webacl_count_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "~> 3.0"

  count = var.web_acl_visibility_config.cloudwatch_metrics_enabled ? 1 : 0

  alarm_name          = "waf-"
  actions_enabled     = var.env_short == "p" ? true : false
  alarm_description   = "Alarm when webacl count greater than 10"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 10
  period              = 60
  unit                = "Count"

  namespace   = "AWS/WAFV2"
  metric_name = "CountedRequests"
  statistic   = "Sum"

  dimensions = {
    "webacl" = {
      WebACL = aws_wafv2_web_acl.main.name
      Ragion = var.aws_region
      Rule   = aws_wafv2_web_acl.main.name
    },
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}