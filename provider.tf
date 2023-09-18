provider "aws" {
  region = var.region

}

terraform {

  required_version = ">= 1.3.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.63.0"
    }

    external = {
      source = "hashicorp/external"
    }

    local = {
      source = "hashicorp/local"
    }

    random = {
      source = "hashicorp/random"
    }
    null = {
      source = "hashicorp/null"
    }

  }
}