data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket              = "tcdx-${var.env}-cloudfront-logs-bucket"
  object_lock_enabled = false
  request_payer       = "BucketOwner"
  tags                = {}
  tags_all            = {}

  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = true

      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled    = false
    mfa_delete = false
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    object_ownership = "ObjectWriter"
  }

  depends_on = [
    aws_s3_bucket.cloudfront_logs
  ]
}

resource "aws_s3_bucket_public_access_block" "cloudfront_access_block" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.cloudfront_logs
  ]
}

resource "aws_s3_bucket_acl" "cloudfront_acl" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  access_control_policy {
    grant {
      permission = "FULL_CONTROL"

      grantee {
        id   = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
        type = "CanonicalUser"
      }
    }
    grant {
      permission = "FULL_CONTROL"

      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }

  depends_on = [
    aws_s3_bucket.cloudfront_logs,
    aws_s3_bucket_public_access_block.cloudfront_access_block,
    aws_s3_bucket_ownership_controls.main
  ]
}
