provider "aws" {
  region = "eu-west-1"
}

#####
# Web Application Firewall configuration
#####
module "waf" {
  source = "../.."

  name_prefix = "test-waf-setup"

  allow_default_action = true

  scope = "REGIONAL"

  create_alb_association = false

  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "test-waf-setup-waf-main-metrics"
    sampled_requests_enabled   = false
  }

  rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet-rule-1"
      priority = "1"

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "AWSManagedRulesCommonRuleSet-metric"
        sampled_requests_enabled   = false
      }

      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        excluded_rule = [
          "SizeRestrictions_QUERYSTRING",
          "SizeRestrictions_BODY",
          "GenericRFI_QUERYARGUMENTS"
        ]
      }
    },
    {
      name     = "block-specific-uri-path"
      priority = "2"
      action   = "block"

      byte_match_statement = {
        field_to_match = {
          uri_path = "{}"
        }
        positional_constraint = "STARTS_WITH"
        search_string         = "/path/to/match"
        priority              = 0
        type                  = "NONE" # The text transformation type
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        sampled_requests_enabled   = false
      }
    },
    {
      name     = "block-if-request-body-contains-hotmail-email"
      priority = "3"
      action   = "block"

      byte_match_statement = {
        field_to_match = {
          body = "{}"
        }
        positional_constraint = "CONTAINS"
        search_string         = "@hotmail.com"
        priority              = 0
        type                  = "NONE" # The text transformation type
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        sampled_requests_enabled   = false
      }
    },
    {
      name     = "block-all-post-requests"
      priority = "4"
      action   = "block"

      byte_match_statement = {
        field_to_match = {
          method = "{}"
        }
        positional_constraint = "EXACTLY"
        search_string         = "post"
        priority              = 0
        type                  = "LOWERCASE" # The text transformation type
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        sampled_requests_enabled   = false
      }
    }
  ]

  tags = {
    "Environment" = "test"
  }
}
