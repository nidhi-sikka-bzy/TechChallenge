data "archive_file" "bucket_check" {
  for_each    = toset(local.create_replication_resources ? ["true"] : [])
  type        = "zip"
  output_path = "${path.root}/.artifacts/aws/bucket/lambda_bucket_check-${random_uuid.this.result}.zip"

  source {
    content  = file("${path.module}/src/s3_bucket_check.py")
    filename = "s3_bucket_check.py"
  }
}

data "aws_lambda_invocation" "bucket_check" {
  for_each      = aws_lambda_function.bucket_check
  depends_on    = [aws_cloudwatch_log_group.bucket_check]
  function_name = each.value.function_name

  input = jsonencode(local.input_lambda)
}

resource "aws_cloudwatch_log_group" "bucket_check" {
  for_each          = aws_lambda_function.bucket_check
  name              = "/aws/lambda/${each.value.function_name}"
  retention_in_days = 14
  tags              = local.tags
}

resource "aws_lambda_function" "bucket_check" {
  for_each         = data.archive_file.bucket_check
  function_name    = local.function_name
  role             = aws_iam_role.lambda-replication[each.key].arn
  runtime          = "python3.8"
  handler          = "s3_bucket_check.handler"
  timeout          = 30
  filename         = each.value.output_path
  source_code_hash = each.value.output_base64sha256
  publish          = true
  tags             = local.tags
}
