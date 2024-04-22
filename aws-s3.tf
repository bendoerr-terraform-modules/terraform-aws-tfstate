# tfsec:ignore:aws-s3-enable-bucket-logging
module "store" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = module.label_store.id
  tags   = module.label_store.tags
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.s3_kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
