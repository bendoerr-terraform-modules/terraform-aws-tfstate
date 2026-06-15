variable "context" {
  type = object({
    attributes     = list(string)
    dns_namespace  = string
    environment    = string
    instance       = string
    instance_short = string
    namespace      = string
    region         = string
    region_short   = string
    role           = string
    role_short     = string
    project        = string
    tags           = map(string)
  })
  description = "Shared Context from Ben's terraform-null-context"
}

variable "enable_legacy_dynamodb_locking" {
  type        = bool
  default     = false
  description = "When true, provisions the legacy DynamoDB lock table (and its IAM policy) for use with the s3 backend's `dynamodb_table` argument. Defaults to false; consumers should configure `use_lockfile = true` on their s3 backend and rely on S3 native state locking. Set to true only if you need to keep the DynamoDB table available during a migration, or if you're pinned to a Terraform version that does not support S3 native locking. See https://developer.hashicorp.com/terraform/language/backend/s3."
  nullable    = false
}

variable "dynamodb_kms_key_arn" {
  type        = string
  default     = null
  description = "[DEPRECATED — only consulted when `enable_legacy_dynamodb_locking = true`.] The ARN of a customer-managed AWS KMS key to use for server-side encryption of the DynamoDB state-lock table. When null, the AWS-managed DynamoDB default key is used."
  nullable    = true
}

variable "s3_kms_key_arn" {
  type        = string
  default     = null
  description = "The ARN of a customer-managed AWS KMS key to use for server-side encryption of the S3 Terraform state bucket. When null, the AWS-managed S3 default key (aws/s3) is used."
  nullable    = true
}
