output "id" {
  value = aws_s3_bucket.bucket.id
}

output "arn" {
  value = aws_s3_bucket.bucket.arn
}

output "write_policy" {
  value = {
    document = data.aws_iam_policy_document.write.json
  }
}

output "read_policy" {
  value = {
    document = data.aws_iam_policy_document.read.json
  }
}

output "crud_policy" {
  value = {
    document = data.aws_iam_policy_document.crud.json
  }
}
