locals {
  signals = toset(["metrics", "logs", "traces", "profiles"])
}

module "bucket" {
  source   = "terraform-aws-modules/s3-bucket/aws"
  version  = "~> 4.0"
  for_each = local.signals

  bucket                  = "${var.prefix}-obs-${each.key}-${var.env}"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = { enabled = true }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_arn
      }
      bucket_key_enabled = true
    }
  }

  lifecycle_rule = [{
    id      = "tiering-and-expiry"
    enabled = true
    transition = [{
      days          = 30
      storage_class = "STANDARD_IA"
    }]
    expiration = {
      days = var.expire_days[each.key]
    }
    noncurrent_version_expiration = {
      noncurrent_days = 7
    }
  }]

  tags = var.tags
}
