resource "aws_cloudwatch_log_metric_filter" "api-gateway-throttle-log-filter" {
  count = var.enable_throttle_alarm ? 1 : 0

  name           = "${var.name}-throttle-filter"
  pattern        = "\"Method completed with status: 429\""
  log_group_name = aws_cloudwatch_log_group.api-gateway-log-group.name

  metric_transformation {
    name      = "ThrottleError"
    namespace = var.name
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "api-gateway-throttle-alarm" {
  count = var.enable_throttle_alarm ? 1 : 0

  alarm_name        = "${var.name}-throttle"
  alarm_description = var.description
  actions_enabled   = true

  alarm_actions = var.alarm_topic_arns
  ok_actions    = var.ok_topic_arns

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.throttleAlarmThreshold
  treat_missing_data  = "notBreaching"

  # conflicts with metric_query
  metric_query {
    id = "throttleErrorCount"

    metric {
      metric_name = "ThrottleError"
      namespace   = var.name
      period      = 60
      stat        = "Sum"
    }
  }

  metric_query {
    id = "invocations"

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ApiName = var.name
      }
    }
  }

  metric_query {
    id = "throttleRate"

    expression  = " ( throttleErrorCount / invocations ) * 100"
    label       = "API Gateway Throttle error rate (percentage)"
    return_data = "true"
  }
}

resource "aws_cloudwatch_metric_alarm" "api-gateway-5xx-alarm" {
  alarm_name        = "${var.name}-5xx"
  alarm_description = var.description
  actions_enabled   = true

  alarm_actions = var.alarm_topic_arns
  ok_actions    = var.ok_topic_arns

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.alarmThreshold5xx
  treat_missing_data  = "notBreaching"

  metric_name = "5XXError"
  namespace   = "AWS/ApiGateway"
  period      = 60
  statistic   = "Average"
  unit        = "Count"
  dimensions  = { "ApiName" = var.name, "Stage" = var.stage_name }
}
