# resource "aws_s3_bucket" "logs" {
#   bucket = var.logs_bucket_name
# }
#
# resource "aws_cloudfront_origin_access_control" "oac" {
#   name                              = "${var.project_name}-oac"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }
#
# resource "aws_wafv2_web_acl" "this" {
#   name  = "${var.project_name}-waf"
#   scope = "CLOUDFRONT"
#
#   default_action {
#     allow {}
#   }
#
#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "waf"
#     sampled_requests_enabled   = true
#   }
#
#   rule {
#     name     = "RateLimit"
#     priority = 1
#
#     action {
#       captcha {}
#     }
#
#     statement {
#       rate_based_statement {
#         limit              = 200
#         aggregate_key_type = "IP"
#       }
#     }
#
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "rate"
#       sampled_requests_enabled   = true
#     }
#   }
# }
#
# resource "aws_cloudfront_response_headers_policy" "security" {
#   name = "${var.project_name}-headers"
#
#   security_headers_config {
#     strict_transport_security {
#       access_control_max_age_sec = 31536000
#       include_subdomains         = true
#       preload                    = true
#       override                   = true
#     }
#
#     content_type_options {
#       override = true
#     }
#
#     frame_options {
#       frame_option = "DENY"
#       override     = true
#     }
#   }
# }
#
# resource "aws_cloudfront_distribution" "this" {
#   enabled = true
#
#   aliases = [var.domain_name]
#
#   origin {
#     domain_name              = var.s3_bucket_domain_name
#     origin_id                = "s3-origin"
#     origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
#   }
#
#   default_cache_behavior {
#     target_origin_id       = "s3-origin"
#     viewer_protocol_policy = "redirect-to-https"
#
#     allowed_methods = ["GET", "HEAD"]
#     cached_methods  = ["GET", "HEAD"]
#
#     response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id
#   }
#
#   viewer_certificate {
#     acm_certificate_arn      = var.certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }
#
#   web_acl_id = aws_wafv2_web_acl.this.arn
#
#   logging_config {
#     bucket          = aws_s3_bucket.logs.bucket_domain_name
#     include_cookies = false
#     prefix          = "cloudfront/"
#   }
#
#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
# }