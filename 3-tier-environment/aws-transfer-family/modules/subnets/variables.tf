variable "subnets" {
  description = "A list of subnets inside the VPC"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    name_prefix       = string
  }))
  default = []
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Maps public IP address when launching an EC2 instance in this subnet"
  type        = bool
  default     = true
}

variable "subnet_name_prefix" {
  description = "A list of subnet name prefixes"
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with the resource."
}
