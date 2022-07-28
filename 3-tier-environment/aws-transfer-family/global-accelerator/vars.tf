variable "AWS_REGION" {
  type = string
}

variable "Second_AWS_REGION" {
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

variable "zone_id" {
  type        = string
  description = <<-EOT
    Hosted zone name.
  EOT
}

variable "domain" {
  type        = string
  description = <<-EOT
    The identifier of the AWS Route 53 DNS hosted zone used to register A/AAAA records for the ALB endpoint.
  EOT
}

locals {
  Primary_EIP1   = "sftptransfer-${var.AWS_REGION}-eip1"
  Primary_EIP2   = "sftptransfer-${var.AWS_REGION}-eip2"
  Secondary_EIP1 = "sftptransfer-${var.Second_AWS_REGION}-eip1"
  Secondary_EIP2 = "sftptransfer-${var.Second_AWS_REGION}-eip2"
  ga_name        = "${var.businessunit}-${var.environment}-sftptransfer"
}

variable "tags" {
  type        = map(string)
  default     = { "ops/stack" = "aws/transfer-family" }
  description = "Additional tags associated with the resource."
}

variable "log_bucket" {
  type        = string
  default     = "sftptransfer-family-temp"
  description = <<-EOT
    Name of the bucket for logs
  EOT  
}

variable "endpoint_region" {
  type = object({
    primary   = string
    secondary = string
  })
  description = "AWS Region where global accelerator endpoints will be configured. If needed please specify a secondary region also."
  default = {
    "primary"   = ""
    "secondary" = ""
  }
}

variable "server_endpoint" {
  type = object({
    primary   = list(string)
    secondary = list(string)
  })
  description = "EIP/ALB ARN to be added to global accelerator endpoints."
  default = null
}

data "aws_eip" "peip1" {
  filter {
    name   = "tag:Name"
    values = [local.Primary_EIP1]
  }
}

data "aws_eip" "peip2" {
  filter {
    name   = "tag:Name"
    values = [local.Primary_EIP2]
  }
}

data "aws_eip" "seip1" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = [local.Secondary_EIP1]
  }
}

data "aws_eip" "seip2" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = [local.Secondary_EIP2]
  }
}