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
  description = "TODO"
  nullable    = true
}

variable "s3_kms_key_arn" {
  type        = string
  default     = null
  description = "TODO"
  nullable    = true
}
