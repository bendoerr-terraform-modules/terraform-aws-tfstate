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
