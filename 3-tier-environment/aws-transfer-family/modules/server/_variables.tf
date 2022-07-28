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
  description = <<-EOT
    Name of the product or solution
  EOT  
}

variable "region" {
  type        = string
  description = <<-EOT
    The region where this tf configuration is being deployed to.
  EOT
}

variable "endpoint_details" {
  type = object({
    vpc_id                 = string
    subnet_ids             = list(string)
    address_allocation_ids = list(string)
    security_group_ids     = list(string)
  })
}

variable "tags" {
  type        = map(string)
  description = "Additional tags associated with the resource."
}
