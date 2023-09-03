output "tfstate_id" {
  value = module.tfstate.tfstate_id
}

output "tfstate_arn" {
  value = module.tfstate.tfstate_arn
}

output "lock_table_id" {
  value = module.tfstate.lock_table_id
}

output "lock_table_arn" {
  value = module.tfstate.lock_table_arn
}

output "lock_table_name" {
  value = module.tfstate.lock_table_name
}

output "iam_tfstate_rw_arn" {
  value = module.tfstate.iam_tfstate_rw_arn
}

output "iam_tfstate_rw_id" {
  value = module.tfstate.iam_tfstate_rw_id
}

output "iam_locks_rw_arn" {
  value = module.tfstate.iam_locks_rw_arn
}

output "iam_locks_rw_id" {
  value = module.tfstate.iam_locks_rw_id
}
