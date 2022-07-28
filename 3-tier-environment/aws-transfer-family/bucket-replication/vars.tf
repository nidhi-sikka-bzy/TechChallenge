variable "AWS_REGION" {
  type = string
}

variable "Second_AWS_REGION" {
  type = string
}

variable "route53_zone" {
  type        = string
  description = <<-EOT
    Name of route53 zone as per the environment like dev,uat,prod.
  EOT  
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

variable "tags" {
  type        = map(string)
  default     = { "ops/stack" = "aws/transfer-family" }
  description = "Additional tags associated with the resource."
}
