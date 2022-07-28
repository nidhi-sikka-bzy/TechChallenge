variable "AWS_REGION" {
  type = string
}

variable "cidr_block" {
  description = "CIDR Block of VPC"
  type        = string
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

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "create_eip" {
  description = "Controls if Elastic IPs should be created"
  type        = bool
  default     = true
}

variable "create_vpce" {
  description = "Controls if VPC Endpoint should be created"
  type        = bool
  default     = true
}

variable "create_default_public_routes" {
  description = "Controls if default public routes should be created"
  type        = bool
  default     = true
}

variable "public_route_table_count" {
  type        = number
  description = "Number of public route tables to created, defaults to 1"
  default     = 2
}

data "aws_vpc_endpoint_service" "transfer" {
  service = "transfer.server"
}

variable "create_internet_gateway" {
  description = "Controls if an Internet Gateway is created for public subnets and the related routes that connect them."
  type        = bool
  default     = true
}

variable "elastic_ips_vpc" {
  description = "Create elastic IPs for vpc?"
  type        = bool
  default     = true
}

variable "public_map_public_ip_on_launch" {
  description = "Controls if public IP mapped when EC2 is launched in public subnet"
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  default     = { "ops/stack" = "aws/transfer-family" }
  description = "Additional tags associated with the resource."
}

locals {
  vpc_id                = module.vpc.vpc_id
  vpc_resource_name     = "${var.businessunit}-${var.environment}-sftptransfer-${var.AWS_REGION}"
  igw_resource_name     = "${var.businessunit}-${var.environment}-sftptransfer-${var.AWS_REGION}"
  eip1_resource_name    = "sftptransfer-${var.AWS_REGION}-eip1"
  eip2_resource_name    = "sftptransfer-${var.AWS_REGION}-eip2"
  public_subnet_name_prefix = ["sftptransfer-${var.AWS_REGION}-subnet1","sftptransfer-${var.AWS_REGION}-subnet2"]
  public_route_name_prefix = ["sftptransfer-${var.AWS_REGION}-route1","sftptransfer-${var.AWS_REGION}-route2"]
  public_subnets_config = [
    {
      cidr_block        = cidrsubnet(var.cidr_block, 2, 0)
      availability_zone = tolist(data.aws_vpc_endpoint_service.transfer.availability_zones)[0]
      name_prefix       = "sftptransfer-${var.AWS_REGION}-subnet1"
    },
    {
      cidr_block        = cidrsubnet(var.cidr_block, 2, 1)
      availability_zone = tolist(data.aws_vpc_endpoint_service.transfer.availability_zones)[1]
      name_prefix       = "sftptransfer-${var.AWS_REGION}-subnet2"
    }
  ]
}

variable "product" {
  type        = string
  default     = "sftptransfer"
  description = <<-EOT
    Name of the product or solution
  EOT  
}

variable "endpoint_details" {
  type = object({
    vpc_id                 = string
    vpc_endpoint_id        = string
    subnet_ids             = list(string)
    address_allocation_ids = list(string)
  })
  default = null
}