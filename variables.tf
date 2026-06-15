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

variable "dynamodb_kms_key_arn" {
  type        = string
  default     = null
  description = "The ARN of a customer-managed AWS KMS key to use for server-side encryption of the DynamoDB state-lock table. When null, the AWS-managed DynamoDB default key is used."
  nullable    = true
}

variable "s3_kms_key_arn" {
  type        = string
  default     = null
  description = "The ARN of a customer-managed AWS KMS key to use for server-side encryption of the S3 Terraform state bucket. When null, the AWS-managed S3 default key (aws/s3) is used."
  nullable    = true
}
