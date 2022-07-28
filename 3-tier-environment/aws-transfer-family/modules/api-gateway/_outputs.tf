output "id" {
  value       = aws_api_gateway_rest_api.api-gateway.id
  description = "The id of the REST API Gateway."
}

output "execution_arn" {
  value       = aws_api_gateway_rest_api.api-gateway.execution_arn
  description = "The ARN of the REST API Gateway."
}

output "alarm_5xx" {
  value = {
    id  = aws_cloudwatch_metric_alarm.api-gateway-5xx-alarm.id
    arn = aws_cloudwatch_metric_alarm.api-gateway-5xx-alarm.arn
  }
  description = "The id and arn of the cloudwatch alarm for [5XX](https://http.cat/500) status codes."
}

output "throttle_alarm" {
  value = var.enable_throttle_alarm ? {
    id  = aws_cloudwatch_metric_alarm.api-gateway-throttle-alarm[0].id
    arn = aws_cloudwatch_metric_alarm.api-gateway-throttle-alarm[0].arn
  } : null
  description = "The id and arn of the cloudwatch alarm for throttling events."
}

output "invoke_url" {
  value = aws_api_gateway_stage.stage.invoke_url
  description = "The invoke url of the default stage. This is required for transfer family custom identity provider."
}
