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
