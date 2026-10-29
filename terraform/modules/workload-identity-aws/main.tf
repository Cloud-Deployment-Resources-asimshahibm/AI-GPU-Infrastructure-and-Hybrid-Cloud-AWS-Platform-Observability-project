# IRSA roles so Thanos, Loki, Tempo and Pyroscope write to their buckets with no static keys.
data "aws_iam_policy_document" "bucket_rw" {
  for_each = var.service_buckets
  statement {
    actions   = ["s3:ListBucket"]
    resources = [each.value]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${each.value}/*"]
  }
  statement {
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey"]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_policy" "bucket_rw" {
  for_each = var.service_buckets
  name     = "${var.prefix}-obs-${each.key}-rw"
  policy   = data.aws_iam_policy_document.bucket_rw[each.key].json
}

module "irsa" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version  = "~> 5.0"
  for_each = var.service_buckets

  role_name = "${var.prefix}-obs-${each.key}"
  role_policy_arns = {
    bucket = aws_iam_policy.bucket_rw[each.key].arn
  }
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = var.service_accounts[each.key]
    }
  }
}

# Read-only CloudWatch role for YACE
module "yace" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.prefix}-obs-yace"
  role_policy_arns = {
    cw  = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
    tag = "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorReadOnlyAccess"
  }
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["observability:yace"]
    }
  }
}
