###################
# WAF Configuration
###################
resource "aws_wafv2_web_acl" "wordpress_waf" {
  name        = "wordpress-waf"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "wordpress-waf"
    sampled_requests_enabled   = true
  }
}

###########################################
 # Attach WAF to Application Load Ballancer
###########################################

resource "aws_wafv2_web_acl_association" "waf-acl" {
  resource_arn = aws_lb.wordpress_lb.arn  
  web_acl_arn  = aws_wafv2_web_acl.wordpress_waf.arn
}
