output "tfstate_id" {
  value = module.store.s3_bucket_id
}

output "tfstate_arn" {
  value = module.store.s3_bucket_arn
}

output "lock_table_id" {
  value = aws_dynamodb_table.locks.id
}

output "lock_table_arn" {
  value = aws_dynamodb_table.locks.arn
}

output "lock_table_name" {
  value = aws_dynamodb_table.locks.name
}

output "iam_tfstate_rw_arn" {
  value = aws_iam_policy.s3_rw.arn
}

output "iam_tfstate_rw_id" {
  value = aws_iam_policy.s3_rw.id
}

output "iam_locks_rw_arn" {
  value = aws_iam_policy.state_dynamodb_rw.arn
}

output "iam_locks_rw_id" {
  value = aws_iam_policy.state_dynamodb_rw.id
}
