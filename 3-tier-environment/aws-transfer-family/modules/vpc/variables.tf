variable "vpc_resource_name" {
  description = "VPC resource name"
  type        = string
  default     = ""
}

variable "cidr_block" {
  description = "CIDR Block of VPC"
  type        = string
  default     = ""
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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with the resource."
}

variable "create_flow_log" {
  type = bool
  default = true 
}

variable "log_group_arn" {
  type = string
  default = "" 
}

variable "iam_role_arn" {
  type = string  
  default = ""
}

variable "traffic_type" {
  type = string
  default = "ALL" 
}

locals {
  vpc_flow_log_group_role_name   = "${var.vpc_resource_name}-role"
  vpc_flow_log_group_policy_name = "${var.vpc_resource_name}-policy"
  vpc_flow_log_group_name        = "${var.vpc_resource_name}-logs"
}