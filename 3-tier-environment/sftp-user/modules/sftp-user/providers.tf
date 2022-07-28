terraform {
  #required_version = ">= 0.13.0"
  required_version = ">= 0.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
}

provider "aws" {
  region = var.Client_REGION
  alias  = "client_region"
}