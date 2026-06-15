output "bucket_id" {
  value = module.tfstate.bucket_id
}

output "lock_table_name" {
  value = module.tfstate.lock_table_name
}

output "lock_table_arn" {
  value = module.tfstate.lock_table_arn
}
