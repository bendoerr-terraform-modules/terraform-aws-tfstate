data "aws_iam_policy_document" "dynamodb_rw" {
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
      aws_dynamodb_table.locks.arn,
    ]
  }
}

resource "aws_iam_policy" "state_dynamodb_rw" {
  name        = module.label_dynamodb_rw.id
  tags        = module.label_dynamodb_rw.tags
  description = "Read/write access to the Terraform state DynamoDB lock table."
  policy      = data.aws_iam_policy_document.dynamodb_rw.json
}

# Point in time recovery is not needed.
#tfsec:ignore:aws-dynamodb-enable-recovery
resource "aws_dynamodb_table" "locks" {
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
