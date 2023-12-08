output "bucket_id" {
  value = module.store.s3_bucket_id
}

output "bucket_arn" {
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

output "iam_s3_rw_arn" {
  value = aws_iam_policy.s3_rw.arn
}

output "iam_s3_rw_id" {
  value = aws_iam_policy.s3_rw.id
}

output "iam_locks_rw_arn" {
  value = aws_iam_policy.dynamodb_rw.arn
}

output "iam_locks_rw_id" {
  value = aws_iam_policy.dynamodb_rw.id
}

output "backend_role_arn" {
  value = length(aws_iam_role.backend) > 0 ? aws_iam_role.backend[0].arn : ""
}
