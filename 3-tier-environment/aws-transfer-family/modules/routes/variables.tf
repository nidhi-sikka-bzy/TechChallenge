variable "create_routes" {
  description = "Controls if default routes should be created"
  type        = bool
  default     = true
}

variable "count_of_public_subnets" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "route_name_prefix" {
  description = "List of route name prefixes"
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "igw_id" {
  description = "Internet Gateway ID"
  type        = string
  default     = ""
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with the resource."
}

variable "public_route_table_count" {
  description = "Number of public route tables to created, defaults to 1"
  type = number
  default = 1
}
