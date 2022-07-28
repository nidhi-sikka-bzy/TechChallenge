terraform {
  backend "s3" {
    bucket = "terraform-state-dev-us-west-2"
    key = "terraform.tfstate"
    region = "us-west-2"
  }
}