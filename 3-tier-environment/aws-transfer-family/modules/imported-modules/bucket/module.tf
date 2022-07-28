data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_s3_bucket" "bucket" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
  tags          = local.tags

  dynamic "logging" {
    for_each = local.logging
    content {
      target_bucket = logging.value["target_bucket"]
      target_prefix = logging.value["target_prefix"]
    }
  }

  acl = var.acl

  versioning {
    enabled = true
  }

  dynamic "lifecycle_rule" {
    for_each = local.lifecycle_rule
    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      abort_incomplete_multipart_upload_days = 7
      enabled                                = true

      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]
        content {
          days = lookup(expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "noncurrent_version_expiration", {})]
        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])
        content {
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])
        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  dynamic "object_lock_configuration" {
    for_each = { for i, v in local.object_lock_config : i => v }
    content {
      object_lock_enabled = "Enabled"
      rule {
        default_retention {
          mode = "GOVERNANCE"
          days = var.object_lock_retention
        }
      }
    }
  }

  dynamic "replication_configuration" {
    for_each = { for i, v in local.replication_config : i => v }
    content {
      role = aws_iam_role.replication[replication_configuration.value].arn

      dynamic "rules" {
        for_each = local.secondary_buckets_with_kms_keys
        content {
          destination {
            bucket = rules.key
            replica_kms_key_id = (rules.value != null
              ? "arn:${local.aws_partition}:kms:${local.secondary_bucket_arns[rules.key]}:${local.account_id}:${rules.value}"
              : "arn:${local.aws_partition}:kms:${local.secondary_bucket_arns[rules.key]}:${local.account_id}:alias/aws/s3"
            )
          }

          id       = "${substr(parseint(md5(rules.key), 16), 0, 3)}-${local.secondary_bucket_arns[rules.key]}"
          priority = substr(parseint(md5(rules.key), 16), 0, 3)
          filter {
            prefix = ""
            tags   = {}
          }
          source_selection_criteria {
            sse_kms_encrypted_objects {
              enabled = true
            }
          }

          status = "Enabled"
        }
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_alias != null ? "arn:${local.aws_partition}:kms:${local.current_region}:${local.account_id}:${var.kms_key_alias}" : null
        sse_algorithm     = var.kms_key_alias == null ? "AES256" : "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "crud" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetLifecycleConfiguration",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutLifecycleConfiguration",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "write" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutLifecycleConfiguration"
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion",
      "s3:GetLifecycleConfiguration"
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "random_uuid" "this" {
  keepers = {
    for filename in fileset(local.src_directory, "**/*") :
    filename => filemd5("${local.src_directory}/${filename}")
  }
}
