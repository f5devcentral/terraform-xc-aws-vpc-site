terraform {
  required_version = ">= 1.0"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.34"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0"
    }
  }
}