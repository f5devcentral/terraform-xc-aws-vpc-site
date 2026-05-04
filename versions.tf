terraform {
  required_version = ">= 1.0"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.49"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.9.0"
    }
  }
}
