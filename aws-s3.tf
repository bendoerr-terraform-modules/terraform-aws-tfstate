module "label_store" {
  source  = "git@github.com:bendoerr/terraform-null-label?ref=v0.4.0"
  context = var.context
  name    = "store"
}

module "store" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

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
        kms_master_key_id = data.aws_kms_alias.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}