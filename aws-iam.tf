module "label_dynamodb_rw" {
  source  = "bendoerr-terraform-modules/label/null"
  version = "0.4.1"
  context = var.context
  name    = "dynamodb-rw"
}

data "aws_iam_policy_document" "dynamodb_rw" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
    resources = [aws_dynamodb_table.locks.arn]
  }
}

data "aws_iam_policy_document" "dynamodb_rw_enc" {
  count = var.dynamodb_kms_key_arn != null ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
    ]
    resources = [var.dynamodb_kms_key_arn]
  }
}

data "aws_iam_policy_document" "dynamodb_rw_combined" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.dynamodb_rw.json],
    var.dynamodb_kms_key_arn != null ? [data.aws_iam_policy_document.dynamodb_rw_enc[0].json] : []
  )
}

resource "aws_iam_policy" "state_dynamodb_rw" {
  name   = module.label_dynamodb_rw.id
  tags   = module.label_dynamodb_rw.tags
  policy = data.aws_iam_policy_document.dynamodb_rw_combined.json
}

module "label_s3_rw" {
  source  = "bendoerr-terraform-modules/label/null"
  version = "0.4.1"
  context = var.context
  name    = "s3-rw"
}

# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "s3_rw" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${module.store.s3_bucket_arn}:*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [module.store.s3_bucket_arn]
  }
}

data "aws_iam_policy_document" "s3_rw_enc" {
  count = var.s3_kms_key_arn != null ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
    ]
    resources = [var.s3_kms_key_arn]
  }
}

data "aws_iam_policy_document" "s3_rw_combined" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.s3_rw.json],
    var.dynamodb_kms_key_arn != null ? [data.aws_iam_policy_document.s3_rw_enc[0].json] : []
  )
}

resource "aws_iam_policy" "s3_rw" {
  name   = module.label_s3_rw.id
  tags   = module.label_s3_rw.tags
  policy = data.aws_iam_policy_document.s3_rw.json
}
