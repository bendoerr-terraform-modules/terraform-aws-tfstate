module "label_locks" {
  source  = "git@github.com:bendoerr/terraform-null-label?ref=v0.4.0"
  context = var.context
  name    = "locks"
}

resource "aws_dynamodb_table" "locks" {
  name = module.label_locks.id
  tags = module.label_locks.tags

  hash_key = "LockID"

  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}