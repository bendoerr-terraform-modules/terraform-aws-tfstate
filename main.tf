module "label_store" {
  source  = "bendoerr-terraform-modules/label/null"
  version = "1.0.0"
  context = var.context
  name    = "store"
}

module "label_locks" {
  source  = "bendoerr-terraform-modules/label/null"
  version = "1.0.0"
  context = var.context
  name    = "locks"
}
