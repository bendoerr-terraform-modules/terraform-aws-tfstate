module "label_store" {
  source  = "bendoerr-terraform-modules/label/null"
  version = "0.5.0"
  context = var.context
  name    = "store"
}

module "label_locks" {
  source  = "bendoerr-terraform-modules/label/null"
  version = "0.5.0"
  context = var.context
  name    = "locks"
}

module "label_store_rw" {
  source  = "bendoerr-terraform-modules/label/null"
  version = "0.5.0"
  context = var.context
  name    = "store-rw"
}

module "label_locks_rw" {
  source  = "bendoerr-terraform-modules/label/null"
  version = "0.5.0"
  context = var.context
  name    = "locks-rw"
}
