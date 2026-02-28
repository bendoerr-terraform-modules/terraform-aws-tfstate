data "aws_iam_policy_document" "s3_rw" {
  statement {
    sid    = "AllowListBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      module.store.s3_bucket_arn,
    ]
  }

  statement {
    sid    = "AllowReadWrite"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${module.store.s3_bucket_arn}/*",
    ]
  }

  dynamic "statement" {
    for_each = var.s3_kms_key_arn != null ? [var.s3_kms_key_arn] : []

    content {
      sid    = "AllowS3KMS"
      effect = "Allow"

      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
      ]

      resources = [
        statement.value,
      ]
    }
  }
}

resource "aws_iam_policy" "s3_rw" {
  name        = module.label_s3_rw.id
  tags        = module.label_s3_rw.tags
  description = "Read/write access to the Terraform state S3 bucket."
  policy      = data.aws_iam_policy_document.s3_rw.json
}

# tfsec:ignore:aws-s3-enable-bucket-logging
module "store" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket = module.label_store.id
  tags   = module.label_store.tags
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.s3_kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
