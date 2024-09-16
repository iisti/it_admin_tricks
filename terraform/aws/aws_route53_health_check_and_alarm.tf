terraform {
  required_version = ">= 1.5.5"
  backend "s3" {
    bucket = "bucket-name"
    key    = "aws-network-checks_and_alarms"
    region = "eu-central-1"
  }
}

locals {
  email_alert = "example@mail.com"
  region      = "us-east-1" # Route53 check and alarm doesn't work properly if not in us-east-1
  owner       = "123456789012"

}

provider "aws" {
  region = local.region
}

resource "aws_route53_health_check" "example_page" {
  fqdn              = "example-page.example.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/path-if-needed"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "example-page"
  }
}

resource "aws_sns_topic" "health_check_example_page" {
    name                                     = "health-check-example-page"
    policy                                   = jsonencode(
        {
            Id        = "__default_policy_ID"
            Statement = [
                {
                    Action    = [
                        "SNS:GetTopicAttributes",
                        "SNS:SetTopicAttributes",
                        "SNS:AddPermission",
                        "SNS:RemovePermission",
                        "SNS:DeleteTopic",
                        "SNS:Subscribe",
                        "SNS:ListSubscriptionsByTopic",
                        "SNS:Publish",
                    ]
                    Condition = {
                        StringEquals = {
                            "AWS:SourceOwner" = "${local.owner}"
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        AWS = "*"
                    }
                    Resource  = "arn:aws:sns:${local.region}:${local.owner}:health-check-example-page"
                    Sid       = "__default_statement_ID"
                },
            ]
            Version   = "2008-10-17"
        }
    )
    tags                                     = {}
    tags_all                                 = {}
}

resource "aws_sns_topic_subscription" "health_check_example_page" {
    endpoint                       = local.email_alert
    protocol                       = "email"
    topic_arn                      = aws_sns_topic.health_check_example_page.arn
}

resource "aws_cloudwatch_metric_alarm" "example_page" {
  actions_enabled     = true
  alarm_actions       = [
    "arn:aws:sns:${local.region}:${local.owner}:health-check-example-page",
  ]
  alarm_description   = "Check that the site is up."
  alarm_name          = "example-page"
  comparison_operator = "LessThanThreshold"
  dimensions                            = {
      HealthCheckId = "${aws_route53_health_check.example_page.id}"
  }
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
}