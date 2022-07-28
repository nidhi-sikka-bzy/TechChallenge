terraform {
  #required_version = ">= 1.0"
  required_version = ">= 0.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
