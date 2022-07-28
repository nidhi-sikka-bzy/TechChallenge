variable "name" {
  type        = string
  description = "The name of the bucket."

  validation {
    condition     = can(regex("^[[:alpha:]]+[[:alnum:]-]+[[:alnum:]]+$", var.name))
    error_message = "The name must contain only letters, numbers, or hypen (-). It must start with a letter and cannot end with a hyphen."
  }
}

variable "domain" {
  type        = string
  description = "The fully-qualified domain name associated with the product"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for bucket."
}

variable "log_bucket" {
  type        = string
  default     = null
  description = "The name of the bucket that will receive the log objects."
}

variable "log_prefix" {
  type        = string
  default     = null
  description = "To specify a key prefix for log objects."
}

variable "acl" {
  type        = string
  default     = "private"
  description = "The canned ACL to apply. Defaults to private."
}

variable "kms_master_key_id" {
  type        = string
  description = "(Optional) The ID of the KMS key to use to encrypt the bucket. If not specified, AES256 encryption will be used."
  default     = null
}

variable "lifecycle_rule" {
  type        = string
  description = "Lifecycle applied to objects in bucket.  Transient permanently deletes all objects/versions after 180 days!"
  default     = "permanent"
}

locals {
  logging = var.log_bucket == null ? [] : [
    {
      target_bucket = var.log_bucket
      target_prefix = var.log_prefix
    }
  ]

  lifecycle_rules = {
    permanent = [
      {
        id = "permanent"
        transition = [
          {
            days          = 7
            storage_class = "INTELLIGENT_TIERING"
          }
        ]
        noncurrent_version_transition = [
          {
            days          = 7
            storage_class = "INTELLIGENT_TIERING"
          }
        ]
        noncurrent_version_expiration = {
          days = 90
        }
      }
    ],
    archive = [
      {
        id = "archive"
        transition = [
          {
            days          = 14
            storage_class = "GLACIER"
          }
        ]
        noncurrent_version_transition = [
          {
            days          = 14
            storage_class = "GLACIER"
          }
        ]
      }
    ],
    transient = [
      {
        id = "transient"
        transition = [
          {
            days          = 7
            storage_class = "INTELLIGENT_TIERING"
          }
        ]
        noncurrent_version_transition = [
          {
            days          = 7
            storage_class = "INTELLIGENT_TIERING"
          }
        ]
        noncurrent_version_expiration = {
          days = 30
        }
        expiration = {
          days = 90
        }
      }
    ]
  }

  lifecycle_rule = lookup(local.lifecycle_rules, var.lifecycle_rule)
  domain         = var.domain
  bucket_name    = "${var.name}"
  tags           = merge(var.tags, { "ops/module" = "aws/bucket", Name = var.name })
}
