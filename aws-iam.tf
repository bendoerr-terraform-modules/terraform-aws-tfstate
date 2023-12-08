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

resource "aws_iam_policy" "dynamodb_rw" {
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
  policy = data.aws_iam_policy_document.s3_rw_combined.json
}

locals {
  use_caller = var.create_backend_role && var.backend_assume_default
  backend_principals = var.create_backend_role ? flatten([
    var.backend_assume_default ? [{ type : "AWS", identifiers : [data.aws_caller_identity.this[0].arn] }] : [],
    var.backend_assume_principals != null ? var.backend_assume_principals : []
  ]) : []
  create_backend_role = var.create_backend_role && length(local.backend_principals) > 0
}

data "aws_caller_identity" "this" {
  count = local.use_caller ? 1 : 0
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_backend_role ? 1 : 0

  dynamic "statement" {
    for_each = local.backend_principals
    #    iterator = "principal"
    content {
      actions = ["sts:AssumeRole"]
      principals {
        type        = statement.value["type"]
        identifiers = statement.value["identifiers"]
      }
    }
  }
}

module "label_backend" {
  count   = local.create_backend_role ? 1 : 0
  source  = "bendoerr-terraform-modules/label/null"
  version = "0.4.1"
  context = var.context
  name    = "backend"
}

resource "aws_iam_role" "backend" {
  count              = local.create_backend_role ? 1 : 0
  name               = module.label_backend[0].id
  tags               = module.label_backend[0].tags
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "backend_s3" {
  count      = local.create_backend_role ? 1 : 0
  role       = aws_iam_role.backend[0].id
  policy_arn = aws_iam_policy.s3_rw.arn
}

resource "aws_iam_role_policy_attachment" "backend_dynamodb" {
  count      = local.create_backend_role ? 1 : 0
  role       = aws_iam_role.backend[0].id
  policy_arn = aws_iam_policy.dynamodb_rw.arn
}
