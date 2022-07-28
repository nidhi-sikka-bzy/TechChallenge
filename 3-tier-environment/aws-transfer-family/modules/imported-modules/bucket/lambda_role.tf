resource "aws_iam_role" "lambda-replication" {
  for_each    = toset(local.create_replication_resources ? ["true"] : [])
  name_prefix = "bucket-replication-check-lambda"
  description = "A role used to allow lambda function to execute S3 API's"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda-basic" {
  for_each   = toset(local.create_replication_resources ? ["true"] : [])
  role       = aws_iam_role.lambda-replication[each.key].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-replication" {
  for_each   = aws_iam_role.lambda-replication
  role       = each.value.id
  policy_arn = aws_iam_policy.lambda-replication[each.key].arn
}

data "aws_iam_policy_document" "lambda-assume" {
  statement {
    sid     = "AllowAssume"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda-replication" {
  statement {
    sid = "AllowS3access"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [for region_name in local.regions : "arn:${local.aws_partition}:s3:::${var.name}.${region_name}"]

  }
}

resource "aws_iam_policy" "lambda-replication" {
  for_each    = aws_iam_role.lambda-replication
  name_prefix = "bucket-replication-check-lambda"
  policy      = data.aws_iam_policy_document.lambda-replication.json

  description = "A policy that enables lambda function to execute GetBucketLocation API's on S3 buckets"
  tags        = local.tags
}
