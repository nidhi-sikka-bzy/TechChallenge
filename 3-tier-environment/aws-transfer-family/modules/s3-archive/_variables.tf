variable "source_dir" {
  type        = string
  description = "Package contents of this directory into the s3 archive."
}

variable "bucket" {
  type        = string
  description = "The s3 bucket for the archive."
}

variable "prefix" {
  type        = string
  description = "The prefix of the s3 key for the archive."
}

variable "name" {
  type        = string
  description = "The name of the archive."
}

variable "type" {
  type        = string
  default     = "zip"
  description = "The type of the archive."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with archive."
}

locals {
  tags = merge(var.tags, { "ops/module" = "aws/s3-archive", Name = var.name })
}
