output "bucket" {
  value = aws_s3_bucket_object.s3_archive.bucket
}

output "key" {
  value = aws_s3_bucket_object.s3_archive.key
}
