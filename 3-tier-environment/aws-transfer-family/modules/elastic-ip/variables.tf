variable "create_eip" {
  description = "Controls if Elastic IPs should be created"
  type        = bool
  default     = true
}

variable "eip_resource_name" {
  description = "Elastic IP resource name"
  type        = string
  default     = ""
}

variable "eip_count" {
  description = "Number of Elastic IPs to create"
  type        = number
  default     = 1
}

variable "vpc" {
  description = "Boolean if the EIP is in a VPC or not"
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with the resource."
}