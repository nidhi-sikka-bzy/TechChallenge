resource "aws_cloudwatch_metric_alarm" "lambda-DeadLetterError-alarm" {
  count             = var.enable_throttles_alarm ? 1 : 0
  alarm_name        = "${var.name}-DeadLetterErrorAlarm"
  alarm_description = "Alarm for Lambda - ${var.name} - DeadLetterError"
  actions_enabled   = true

  alarm_actions = var.alarm_topic_arns
  ok_actions    = var.ok_topic_arns

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  treat_missing_data  = "notBreaching"

  # conflicts with metric_query
  metric_name = "DeadLetterErrors"
  namespace   = "AWS/Lambda"
  period      = 60
  statistic   = "Sum"
  unit        = "Count"
  dimensions  = { "FunctionName" = var.name }

}


resource "aws_cloudwatch_metric_alarm" "lambda-Throttles-alarm" {
  count             = var.enable_throttles_alarm ? 1 : 0
  alarm_name        = "${var.name}-ThrottlesAlarm"
  alarm_description = "Alarm for Lambda - ${var.name} - Throttles"
  actions_enabled   = true

  alarm_actions = var.alarm_topic_arns
  ok_actions    = var.ok_topic_arns

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.alarm_threshold_throttles
  treat_missing_data  = "notBreaching"

  metric_query {
    id = "throttleCount"

    metric {
      metric_name = "Throttles"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Sum"

      dimensions = {
        FunctionName = var.name
      }
    }
  }

  metric_query {
    id = "invocations"

    metric {
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Sum"

      dimensions = {
        FunctionName = var.name
      }
    }
  }

  metric_query {
    id = "throttleRate"

    expression  = " ( throttleCount / invocations ) * 100"
    label       = "Lambda Throttle rate percentage"
    return_data = "true"
  }
}
