output "name" {
  value = aws_lambda_function.lambda.function_name
}

output "arn" {
  value = aws_lambda_function.lambda.arn
}

output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "role" {
  value       = module.role
  description = "The details for the Lambda role."
}

output "invoke_policy" {
  value = {
    document = data.aws_iam_policy_document.invoke.json
  }
}

output "dead_letter_queue_arn" {
  value = module.dead-letter-queue.arn
}

output "throttle_alarm" {
  value = var.enable_throttles_alarm ? {
    arn = aws_cloudwatch_metric_alarm.lambda-Throttles-alarm[0].arn
    id  = aws_cloudwatch_metric_alarm.lambda-Throttles-alarm[0].id
  } : null
}

output "dead_letter_error_alarm" {
  value = var.enable_throttles_alarm ? {
    arn = aws_cloudwatch_metric_alarm.lambda-DeadLetterError-alarm[0].arn
    id  = aws_cloudwatch_metric_alarm.lambda-DeadLetterError-alarm[0].id
  } : null
}
