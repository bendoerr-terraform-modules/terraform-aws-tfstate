data "aws_iam_policy_document" "locks_rw" {
  count = var.enable_legacy_dynamodb_locking ? 1 : 0

  statement {
    sid    = "AllowDynamoDBLocks"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
    ]

    resources = [
      aws_dynamodb_table.locks[0].arn,
    ]
  }

  dynamic "statement" {
    for_each = var.dynamodb_kms_key_arn != null && trimspace(var.dynamodb_kms_key_arn) != "" ? [trimspace(var.dynamodb_kms_key_arn)] : []

    content {
      sid    = "AllowDynamoDBKMS"
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

resource "aws_iam_policy" "locks_rw" {
  count = var.enable_legacy_dynamodb_locking ? 1 : 0

  name        = module.label_locks_rw.id
  tags        = module.label_locks_rw.tags
  description = "Read/write access to the Terraform state DynamoDB lock table."
  policy      = data.aws_iam_policy_document.locks_rw[0].json
}

# Point in time recovery is not needed.
#tfsec:ignore:aws-dynamodb-enable-recovery
resource "aws_dynamodb_table" "locks" {
  count = var.enable_legacy_dynamodb_locking ? 1 : 0

  name = module.label_locks.id
  tags = module.label_locks.tags

  hash_key = "LockID"

  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.dynamodb_kms_key_arn
  }
}
