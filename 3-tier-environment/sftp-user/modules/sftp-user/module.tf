data "aws_s3_bucket" "bucket" {
  provider = aws.client_region
  bucket = var.bucket_name
}

resource "aws_s3_bucket_object" "object" {
  provider = aws.client_region
  bucket = var.bucket_name
  key    = "${var.client_name}/"
}

module "sftp_user_role" {
  #provider = aws.client_region
  source  = "../role"
  name    = "${local.name}-role"
  tags    = local.tags
  service = "transfer"
}

resource "aws_iam_role_policy" "policy" {
  #provider = aws.client_region
  name = "${local.name}-policy"
  role = module.sftp_user_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "AllowListingFolder",
        Effect : "Allow",
        Action : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource : data.aws_s3_bucket.bucket.arn,
        Condition : {
          "StringLike" : {
            "s3:prefix" : var.is_admin ? ["*"] : [
              "${var.client_name}/*",
              var.client_name
            ]
          }
        }
      },
      {
        Sid : "AllowReadWriteToObject",
        Effect : "Allow",
        Action : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObjectVersion",
          "s3:DeleteObject",
          "s3:GetObjectVersion"
        ],
        Resource : "${data.aws_s3_bucket.bucket.arn}/${var.client_name}*"
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "secret" {
  name        = "${var.secret_prefix}-${var.client_name}"
  description = "SFTP credentials for ${var.client_name}"
  tags        = merge({ "ops/module-primary" : local.name }, local.tags)
}

resource "aws_secretsmanager_secret_version" "keys" {
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({
    Role                 = module.sftp_user_role.arn
    HomeDirectoryDetails = jsonencode([{ Entry = "/", Target = "/${data.aws_s3_bucket.bucket.bucket}/${var.client_name}" }])
    Password             = var.password
  })
}
