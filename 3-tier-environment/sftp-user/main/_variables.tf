variable "AWS_REGION" {
  type = string
}

variable "Client_REGION" {
  type = string
}

variable "route53_zone" {
  type        = string
  description = <<-EOT
    Name of route53 zone as per the environment like dev,uat,prod.
  EOT  
}

variable "client_name" {
  type = string
}

variable "password" {
  type = string
}

variable "businessunit" {
  type        = string
  description = <<-EOT
    Name of business unit.
  EOT  
}

variable "environment" {
  type        = string
  description = <<-EOT
    environment dev, uat or prod
  EOT
}

variable "product" {
  type        = string
  default     = "sftptransfer"
  description = <<-EOT
    Name of the product or solution
  EOT  
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = <<-EOT
    The region where this tf configuration is being deployed to.
  EOT
}

variable "tags" {
  type        = map(string)
  description = "Additional tags associated with the resource."
  default     = { 
    "ops/managed-by" = "Terraform"
    "ops/stack"     = "aws/transfer-family" 
  }
}
