terraform {
  #required_version = ">= 0.13.0"
  required_version = ">= 0.14.5"
  required_providers {
    aws = {
      version = "~> 3.0"
      source  = "hashicorp/aws"
    }
  }
}