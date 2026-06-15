output "bucket_id" {
  value       = module.store.s3_bucket_id
  description = "The S3 bucket ID where the state will be stored."
}

output "bucket_arn" {
  value       = module.store.s3_bucket_arn
  description = "The S3 bucket ARN where the state will be stored."
}

output "lock_table_id" {
  value       = try(aws_dynamodb_table.locks[0].id, null)
  description = "[DEPRECATED — set `enable_legacy_dynamodb_locking = true` to populate; will be removed in v2.0.0.] The DynamoDB table ID that will be used for distributed locking. Returns null when S3 native locking is in use."
}

output "lock_table_arn" {
  value       = try(aws_dynamodb_table.locks[0].arn, null)
  description = "[DEPRECATED — set `enable_legacy_dynamodb_locking = true` to populate; will be removed in v2.0.0.] The DynamoDB table ARN that will be used for distributed locking. Returns null when S3 native locking is in use."
}

output "lock_table_name" {
  value       = try(aws_dynamodb_table.locks[0].name, null)
  description = "[DEPRECATED — set `enable_legacy_dynamodb_locking = true` to populate; will be removed in v2.0.0.] The DynamoDB table Name that will be used for distributed locking. Returns null when S3 native locking is in use."
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
  value       = try(aws_iam_policy.locks_rw[0].arn, null)
  description = "[DEPRECATED — set `enable_legacy_dynamodb_locking = true` to populate; will be removed in v2.0.0.] The ARN of the IAM policy granting read/write access to the Terraform state DynamoDB lock table. Returns null when S3 native locking is in use."
}

output "iam_locks_rw_id" {
  value       = try(aws_iam_policy.locks_rw[0].id, null)
  description = "[DEPRECATED — set `enable_legacy_dynamodb_locking = true` to populate; will be removed in v2.0.0.] The ID of the IAM policy granting read/write access to the Terraform state DynamoDB lock table. Returns null when S3 native locking is in use."
}
