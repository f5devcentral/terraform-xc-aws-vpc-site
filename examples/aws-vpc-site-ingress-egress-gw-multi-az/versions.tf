terraform {
  required_version = ">= 1.0"

  required_providers {
    volterra = {
        source  = "volterraedge/volterra"
        version = ">=0.11.26"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}
