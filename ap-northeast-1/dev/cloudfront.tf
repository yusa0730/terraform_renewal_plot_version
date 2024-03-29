resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for static site"
}

resource "aws_cloudfront_distribution" "main" {
  aliases             = []
  comment             = "${var.env}環境用のcloudfront"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_200"
  retain_on_delete    = false
  wait_for_deployment = true
  web_acl_id          = aws_wafv2_web_acl.cloudfront.arn
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.static_file.bucket_domain_name
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    smooth_streaming       = false
    path_pattern           = "/api*"
    target_origin_id       = "${aws_api_gateway_rest_api.main.id}.execute-api.${var.region}.amazonaws.com"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Accept",
        "Accept-Encoding",
        "Accept-Language",
        "Authorization",
      ]
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  logging_config {
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    include_cookies = true
    prefix          = "logs/"
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = aws_s3_bucket.static_file.bucket_domain_name
    origin_id           = aws_s3_bucket.static_file.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = "${aws_api_gateway_rest_api.main.id}.execute-api.${var.region}.amazonaws.com"
    origin_id           = "${aws_api_gateway_rest_api.main.id}.execute-api.${var.region}.amazonaws.com"
    # origin_path         = "/${aws_api_gateway_stage.main.stage_name}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  # 現時点で指定のドメイン名が不明なのでACMを利用しない設定にしております。
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

  # 指定のドメイン名を利用する場合は以下を設定
  # viewer_certificate {
  #   acm_certificate_arn            = "指定のacmのarn"
  #   cloudfront_default_certificate = false
  #   minimum_protocol_version       = "TLSv1.2_2021"
  #   ssl_support_method             = "sni-only"
  # }
  depends_on = [
    aws_s3_bucket.cloudfront_logs,
    aws_s3_bucket_public_access_block.cloudfront_access_block,
    aws_s3_bucket_acl.cloudfront_acl,
    aws_s3_bucket_ownership_controls.main,
    aws_s3_bucket.static_file,
    aws_s3_bucket_public_access_block.static_file_access_block,
    # aws_s3_bucket_acl.static_file_acl,
    aws_s3_bucket_ownership_controls.static_file,
    aws_wafv2_web_acl.cloudfront
  ]

  tags = {
    Name      = "${var.project_name}-${var.env}-cloudfront-distribution"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}
