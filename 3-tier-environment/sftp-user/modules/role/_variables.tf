variable "name" {
  type        = string
  default     = null
  description = "The name of the iam role to create."

  validation {
    condition     = can(regex("^[[:alpha:]]+[[:alnum:]-]+[[:alnum:]]+$", coalesce(var.name, "valid")))
    error_message = "The name must contain only letters, numbers, or hypen (-). It must start with a letter and cannot end with a hyphen."
  }
}

variable "name_prefix" {
  type        = string
  default     = null
  description = "The name prefix of the iam role to create. Ignored if the name variable is set."

  validation {
    condition     = can(regex("^[[:alpha:]]+[[:alnum:]-]+[[:alnum:]]+$", coalesce(var.name_prefix, "valid"))) && length(coalesce(var.name_prefix, "valid")) < 32
    error_message = "The name must contain only letters, numbers, or hypen (-). It must start with a letter and cannot end with a hyphen. It cannot exceed 31 characters in length."
  }
}

variable "path" {
  type        = string
  default     = "/"
  description = "The path of the role within IAM."
}

variable "service" {
  type        = string
  description = "The name of service allowed to assume role ie lambda or ec2."
}

variable "description" {
  type        = string
  default     = null
  description = "The description of the IAM role."
}

variable "policy_documents" {
  type        = list(string)
  default     = []
  description = "The list of IAM policy documents for the role."
}

variable "assume_role_policy_document" {
  type        = string
  default     = null
  description = "The list of IAM policy documents allowed to assume the role."
}

variable "policy_arns" {
  type        = list(string)
  default     = []
  description = "The list of pre-existing IAM policy ARNs for role."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with the role."
}

locals {
  has_policies = toset(length(var.policy_documents) > 0 ? ["true"] : [])
  tags         = merge(var.tags, { "ops/module" = "aws/role" })
  name_prefix  = var.name == null ? "${trimsuffix(var.name_prefix, "-")}-" : null
  profile_name = var.name != null ? var.name : trimsuffix(var.name_prefix, "-")
}
