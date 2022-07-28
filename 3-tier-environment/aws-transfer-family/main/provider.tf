terraform {
  #required_version = "~> 1.0"
  required_version = ">= 0.14.5"
  required_providers {
    aws = {
      version = "~> 3.0"
      source  = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = var.AWS_REGION
}