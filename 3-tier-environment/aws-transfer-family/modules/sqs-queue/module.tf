
resource "aws_sqs_queue" "queue" {
  name                       = var.name
  tags                       = merge(local.tags, { "ops/module-primary" : "aws/sqs-queue" })
  visibility_timeout_seconds = var.visibility_timeout
  redrive_policy             = var.redrive_policy_json
}

resource "aws_iam_policy" "write" {
  name        = "${var.name}-sqs-write"
  path        = "/ops/"
  description = "Allow write to ${var.name}"

  policy = data.aws_iam_policy_document.write.json

  tags = local.tags
}

data "aws_iam_policy_document" "write" {
  statement {
    actions = [
      "sqs:SendMessage*"
    ]
    resources = [
      aws_sqs_queue.queue.arn
    ]
  }
}

data "aws_iam_policy_document" "read" {
  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage"
    ]
    resources = [
      aws_sqs_queue.queue.arn
    ]
  }
}



resource "aws_cloudwatch_metric_alarm" "sqs-OldestMessage-alarm" {
  count             = var.enable_oldest_message_alarm ? 1 : 0
  alarm_name        = "${var.name}-OldestMessageAlarm"
  alarm_description = "Alarm for SQS - ${var.name} - ApproximateAgeOfOldestMessage"
  actions_enabled   = true

  alarm_actions = var.alarm_topic_arns
  ok_actions    = var.ok_topic_arns

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.alarm_threshold_oldest_message
  treat_missing_data  = "notBreaching"

  # conflicts with metric_query
  metric_name = "ApproximateAgeOfOldestMessage"
  namespace   = "AWS/SQS"
  period      = 60
  statistic   = "Average"
  unit        = "Count"
  dimensions  = { "QueueName" = var.name }

}


resource "aws_cloudwatch_metric_alarm" "sqs-NumberOfMessagesSent-alarm" {
  count             = var.enable_num_msg_sent_alarm ? 1 : 0
  alarm_name        = "${var.name}-NumberOfMessagesSentAlarm"
  alarm_description = "Alarm for SQS - ${var.name} - NumberOfMessagesSent"
  actions_enabled   = true

  alarm_actions = var.alarm_topic_arns
  ok_actions    = var.ok_topic_arns

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.alarm_threshold_num_msg_sent
  treat_missing_data  = "notBreaching"

  # conflicts with metric_query
  metric_name = "NumberOfMessagesSent"
  namespace   = "AWS/SQS"
  period      = 300
  statistic   = "Average"
  unit        = "Count"


}


