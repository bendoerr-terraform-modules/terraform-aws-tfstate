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

variable "s3_kms_key_arn" {
  type        = string
  default     = null
  description = "The ARN of a customer-managed AWS KMS key to use for server-side encryption of the S3 Terraform state bucket. When null, the AWS-managed S3 default key (aws/s3) is used."
  nullable    = true

  validation {
    # Accept null / blank (= use the AWS-managed default, matching the module's
    # `!= null && trimspace() != ""` usage guard) or a KMS key/alias ARN. The
    # partition is left open (aws / aws-us-gov / aws-cn) and `key/` allows the
    # `mrk-` multi-region key prefix.
    condition     = var.s3_kms_key_arn == null || trimspace(var.s3_kms_key_arn) == "" || can(regex("^arn:aws[a-z-]*:kms:[a-z0-9-]+:[0-9]{12}:(key/[0-9a-zA-Z-]+|alias/[a-zA-Z0-9/_-]+)$", trimspace(var.s3_kms_key_arn)))
    error_message = "s3_kms_key_arn must be null, empty, or a valid KMS key or alias ARN (e.g. arn:aws:kms:us-east-1:123456789012:key/<id> or .../alias/<name>)."
  }
}
