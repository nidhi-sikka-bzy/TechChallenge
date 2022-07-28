variable "name" {
  type        = string
  description = "The name of the bucket."

  validation {
    condition     = can(regex("^[[:alpha:]]+[[:alnum:]-]+[[:alnum:]]+$", var.name))
    error_message = "The name must contain only letters, numbers, or hyphen (-). It must start with a letter and cannot end with a hyphen."
  }
}

variable "domain" {
  type        = string
  description = "The fully-qualified domain name associated with the product / project, such as 'octo.ihsmarkit.com'."
}

variable "regions" {
  type        = list(string)
  #default     = []
  description = "All regions for setting up replication (primary + secondary)"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = <<-EOT
    A value indicating whether or not to delete all objects in the bucket when deleting the bucket.
    NOTE: THIS IS NOT RECOVERABLE AND SHOULD ONLY BE USED DURING TESTING!
  EOT
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

variable "additional_replication_buckets" {
  type = list(object({
    name          = string
    kms_key_alias = string
    region        = string
  }))
  default     = []
  description = "Additional replication buckets on top of auto multi-region replication."
}

variable "object_lock_retention" {
  type        = number
  default     = 2555
  description = "Object lock retention period in days for archival bucket."
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

variable "kms_key_alias" {
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

  # Currently there is no way in terraform to throw validation errors involving computation of > 1 variables
  # below two checks are meant to disallow use of additional replication buckets and multiple regions
  # when using lifecycle rule as archive.
  no_additional_replication_when_archive_bucket = try(
    length(var.additional_replication_buckets) != 0 && var.lifecycle_rule == "archive"
    ? index([var.lifecycle_rule], "throw_error")
    : "throwing_error_when_providing_additional-replication_with_archive_bucket",
  )

  no_replication_regions_when_archive_bucket = try(
    length(var.regions) != 0 && var.lifecycle_rule == "archive"
    ? index([var.lifecycle_rule], "throw_error")
    : "throwing_error_when_providing_replication-regions_with_archive_bucket",
  )

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
            days          = 35
            storage_class = "GLACIER"
          },
          {
            days          = 125
            storage_class = "DEEP_ARCHIVE"
          }
        ]
        noncurrent_version_transition = [
          {
            days          = 35
            storage_class = "GLACIER"
          },
          {
            days          = 125
            storage_class = "DEEP_ARCHIVE"
          }
        ]
        expiration = {
          expired_object_delete_marker = "true"
        }
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
  function_name = "${var.name}-bucket-check"

  additional_replication_bucket_arn_region = {
    for repl in var.additional_replication_buckets :
    repl.name => repl.region
  }

  additional_replication_bucket_arn_kms_key = {
    for repl in var.additional_replication_buckets :
    repl.name => repl.kms_key_alias
  }

  current_region                     = data.aws_region.current.name
  aws_partition                      = data.aws_partition.current.partition
  account_id                         = data.aws_caller_identity.current.account_id
  additional_replication_bucket_arns = keys(local.additional_replication_bucket_arn_region) # list of additional replication buckets
  src_directory                      = "${path.module}/src"
  lifecycle_rule                     = lookup(local.lifecycle_rules, var.lifecycle_rule)
  regions                            = contains(var.regions, local.current_region) ? var.regions : concat(var.regions, [local.current_region])
  secondary_regions                  = setsubtract(var.regions, [local.current_region])
  bucket_name                        = "${var.name}.${local.current_region}"
  tags                               = merge({ "ops/module" = "aws/bucket", Name = var.name }, var.tags)

  secondary_bucket_arns = merge(
    { for region_name in local.secondary_regions :
      "arn:${local.aws_partition}:s3:::${var.name}.${region_name}" => region_name
    }, local.additional_replication_bucket_arn_region
  )
  secondary_bucket_keys = tolist([for region_name in values(local.secondary_bucket_arns) :
    "arn:${local.aws_partition}:kms:${region_name}:${local.account_id}:key/*"]
  )

  # lambda output format if buckets in region2 and region3 exist
  #{'some-bucket-region-1': ['some-bucket-region-2','some-bucket-region-3'], 'some-bucket-region-2': ['some-bucket-region-3'], 'some-bucket-region-3': ['some-bucket-region-2']}

  create_replication_resources = (
    (length(var.regions) > 0 || length(var.additional_replication_buckets) > 0)
    && var.lifecycle_rule != "archive" ? true : false
  )
  lambda_output_bucket_list = (
    local.create_replication_resources
    ? lookup(jsondecode(data.aws_lambda_invocation.bucket_check["true"].result), local.bucket_name, [])
    : []
  )
  secondary_bucket_list = (
    length(local.additional_replication_bucket_arns) == 0
    ? local.lambda_output_bucket_list : concat(local.lambda_output_bucket_list, local.additional_replication_bucket_arns)
  )
  secondary_buckets_with_kms_keys = {
    for i, bucket in local.secondary_bucket_list :
    bucket => lookup(local.additional_replication_bucket_arn_kms_key, bucket, var.kms_key_alias)
  }
  replication_config = length(local.secondary_bucket_list) == 0 || var.lifecycle_rule == "archive" ? [] : ["true"]
  object_lock_config = var.lifecycle_rule == "archive" ? ["true"] : []
  input_lambda = { for region in local.regions :
    region => { "bucket" = "arn:${local.aws_partition}:s3:::${var.name}.${region}" }
  }
}
