resource "aws_api_gateway_rest_api" "api-gateway" {
  name = "${var.name}-${data.aws_region.current.name}"
  body = templatefile(var.open_api_file, var.api_vars)
  tags = merge(local.tags, { "ops/module-primary" = "aws/api-gateway" })
}

resource "aws_api_gateway_stage" "stage" {
  depends_on           = [aws_cloudwatch_log_group.api-gateway-log-group]
  stage_name           = var.stage_name
  rest_api_id          = aws_api_gateway_rest_api.api-gateway.id
  deployment_id        = aws_api_gateway_deployment.api-gateway-deployment.id
  xray_tracing_enabled = var.enable_xray
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api-gateway-log-group.arn
    format          = "$context.identity.sourceIp $context.identity.caller  $context.identity.user [$context.requestTime] $context.httpMethod $context.resourcePath $context.protocol $context.status $context.responseLength $context.requestId"
  }
  tags = local.tags
}

resource "aws_api_gateway_deployment" "api-gateway-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
}

resource "aws_cloudwatch_log_group" "api-gateway-log-group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api-gateway.id}/${var.stage_name}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = var.enable_metrics
    logging_level          = var.log_level
    data_trace_enabled     = var.enable_data_trace
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
    caching_enabled        = var.enable_caching

  }
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_sftptransfer-${data.aws_region.current.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "gateway_logs" {
  role       = aws_iam_role.cloudwatch.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

data "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  path        = "/servers/{serverId}/users/{username}/config"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api-gateway.id
  resource_id             = data.aws_api_gateway_resource.my_resource.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.uri
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api-gateway.id}/*/GET${data.aws_api_gateway_resource.my_resource.path}"
}