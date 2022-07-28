data "archive_file" "s3_archive" {
  type        = var.type
  source_dir  = var.source_dir
  output_path = "${path.root}/.artifacts/aws/${var.prefix}${var.name}.${var.type}"
}

resource "random_pet" "s3_archive" {
  keepers = {
    hash = data.archive_file.s3_archive.output_base64sha256
  }
  length = 2
}

resource "aws_s3_bucket_object" "s3_archive" {
  bucket = var.bucket
  key    = "${var.prefix}${var.name}-${random_pet.s3_archive.id}.${var.type}"
  source = data.archive_file.s3_archive.output_path

  tags = merge(local.tags, { "ops/module-primary" : "aws/s3-archive" })
}
