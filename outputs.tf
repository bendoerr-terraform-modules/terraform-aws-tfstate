output "bucket_id" {
  value       = module.store.s3_bucket_id
  description = "The S3 bucket ID where the state will be stored."
}

output "bucket_arn" {
  value       = module.store.s3_bucket_arn
  description = "The S3 bucket ARN where the state will be stored."
}

output "lock_table_id" {
  value       = aws_dynamodb_table.locks.id
  description = "The DynamoDB table ID that will be used for distributed locking."
}

output "lock_table_arn" {
  value       = aws_dynamodb_table.locks.arn
  description = "The DynamoDB table ARN that will be used for distributed locking."
}

output "lock_table_name" {
  value       = aws_dynamodb_table.locks.name
  description = "The DynamoDB table Name that will be used for distributed locking."
}

output "iam_store_rw_arn" {
  value       = aws_iam_policy.store_rw.arn
  description = "The ARN of the IAM policy granting read/write access to the Terraform state S3 bucket."
}

output "iam_store_rw_id" {
  value       = aws_iam_policy.store_rw.id
  description = "The ID of the IAM policy granting read/write access to the Terraform state S3 bucket."
}

output "iam_locks_rw_arn" {
  value       = aws_iam_policy.locks_rw.arn
  description = "The ARN of the IAM policy granting read/write access to the Terraform state DynamoDB lock table."
}

output "iam_locks_rw_id" {
  value       = aws_iam_policy.locks_rw.id
  description = "The ID of the IAM policy granting read/write access to the Terraform state DynamoDB lock table."
}
