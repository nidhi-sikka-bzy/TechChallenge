module "s3-archive" {
  count      = local.is_zip_package ? 1 : 0
  source     = "../s3-archive"
  bucket     = var.bucket
  prefix     = "lambda/"
  name       = var.name
  source_dir = var.source_dir
  tags       = var.tags
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
  tags              = local.tags
}

resource "aws_lambda_function" "lambda" {
  function_name                  = var.name
  role                           = module.role.arn
  runtime                        = var.runtime
  handler                        = var.handler
  layers                         = var.layers
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  package_type                   = var.package_type

  tracing_config {
    mode = var.enable_active_tracing ? "Active" : "PassThrough"
  }

  dynamic "environment" {
    for_each = local.has_env
    content {
      variables = var.env
    }
  }

  dynamic "vpc_config" {
    for_each = local.has_vpc_name
    content {
      subnet_ids         = data.aws_subnet_ids.private[0].ids
      security_group_ids = var.egress_security_groups
    }
  }

  dynamic "image_config" {
    for_each = local.has_image_config
    content {
      command           = var.image_entry_point
      entry_point       = var.image_command
      working_directory = var.image_working_directory
    }
  }

  s3_bucket = var.bucket
  s3_key    = local.is_zip_package ? module.s3-archive[0].key : null
  image_uri = var.image_uri
  tags      = merge(local.tags, { "ops/module-primary" : "aws/lambda" })
}

data "aws_iam_policy_document" "invoke" {
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      aws_lambda_function.lambda.arn
    ]
  }
}
