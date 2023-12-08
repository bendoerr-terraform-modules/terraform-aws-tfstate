terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "namespace" {
  type = string
}

module "context" {
  source      = "bendoerr-terraform-modules/context/null"
  version     = "0.4.1"
  namespace   = var.namespace
  environment = "example"
  role        = "tfstate"
  region      = "us-east-1"
  project     = "simple"
}
