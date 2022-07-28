output "name" {
  value = aws_sqs_queue.queue.name
}

output "arn" {
  value = aws_sqs_queue.queue.arn
}

output "url" {
  value = aws_sqs_queue.queue.id
}

output "write_policy" {
  value = {
    document = data.aws_iam_policy_document.write.json
  }
}

output "read_policy" {
  value = {
    document = data.aws_iam_policy_document.read.json
  }
}


output "oldest_message_alarm" {
  value = {
    arn = var.enable_oldest_message_alarm ? aws_cloudwatch_metric_alarm.sqs-OldestMessage-alarm[0].arn : null
    id  = var.enable_oldest_message_alarm ? aws_cloudwatch_metric_alarm.sqs-OldestMessage-alarm[0].id : null
  }
}


output "num_msg_sent_alarm" {
  value = {
    arn = var.enable_num_msg_sent_alarm ? aws_cloudwatch_metric_alarm.sqs-NumberOfMessagesSent-alarm[0].arn : null
    id  = var.enable_num_msg_sent_alarm ? aws_cloudwatch_metric_alarm.sqs-NumberOfMessagesSent-alarm[0].id : null
  }
}