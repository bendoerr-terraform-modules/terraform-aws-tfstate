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

resource "aws_iam_policy" "state_dynamodb_rw" {
  name   = module.label_dynamodb_rw.id
  tags   = module.label_dynamodb_rw.tags
  policy = data.aws_iam_policy_document.dynamodb_rw.json
}

module "label_s3_rw" {
  source  = "bendoerr-terraform-modules/label/null"
  version = "0.4.1"
  context = var.context
  name    = "s3-rw"
}

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

resource "aws_iam_policy" "s3_rw" {
  name   = module.label_s3_rw.id
  tags   = module.label_s3_rw.tags
  policy = data.aws_iam_policy_document.s3_rw.json
}