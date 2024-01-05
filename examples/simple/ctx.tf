module "context" {
  source      = "bendoerr-terraform-modules/context/null"
  version     = "0.4.1"
  namespace   = var.namespace
  environment = "example"
  role        = "tfstate"
  region      = "us-east-1"
  project     = "simple"
}
