# Plan Serivice IAM Role
data "aws_iam_policy_document" "assume-s3" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }

}

resource "aws_iam_role" "replication" {
  for_each           = toset(local.create_replication_resources ? ["true"] : [])
  name_prefix        = "bucket_replication"
  assume_role_policy = data.aws_iam_policy_document.assume-s3.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "replication" {
  for_each   = aws_iam_role.replication
  policy_arn = aws_iam_policy.replication[each.key].arn
  role       = each.value.name
}

data "aws_iam_policy_document" "replication" {

  statement {
    sid = "AllowRead"
    actions = [
      "s3:ListBucket",
      "s3:GetReplicationConfiguration",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectRetention",
      "s3:GetObjectLegalHold"
    ]

    resources = [
      "arn:${local.aws_partition}:s3:::${local.bucket_name}",
      "arn:${local.aws_partition}:s3:::${local.bucket_name}/*"
    ]
  }

  statement {
    sid = "AllowReplicate"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetObjectVersionTagging",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = [for bucket in keys(local.secondary_bucket_arns) : "${bucket}/*"]
  }

  statement {
    sid = "AllowDecrypt"
    actions = [
      "kms:Decrypt"
    ]

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.*.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values   = ["arn:${local.aws_partition}:s3:::${local.bucket_name}/*"]
    }

    resources = [
      "arn:${local.aws_partition}:kms:${local.current_region}:${local.account_id}:key/*"
    ]
  }

  statement {
    sid = "AllowEncrypt"
    actions = [
      "kms:Encrypt"
    ]

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.*.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values   = [for bucket in keys(local.secondary_bucket_arns) : "${bucket}/*"]
    }

    resources = local.secondary_bucket_keys
  }
}

resource "aws_iam_policy" "replication" {
  for_each    = aws_iam_role.replication
  name_prefix = "bucket_replication"
  tags        = local.tags
  policy      = data.aws_iam_policy_document.replication.json
}
