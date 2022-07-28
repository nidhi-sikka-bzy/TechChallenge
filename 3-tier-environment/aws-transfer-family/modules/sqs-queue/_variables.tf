variable "name" {
  type        = string
  description = "The name of the lambda function."

  validation {
    condition     = can(regex("^[[:alpha:]]+[[:alnum:]-]+[[:alnum:]]+$", var.name))
    error_message = "The name must contain only letters, numbers, or hypen (-). It must start with a letter and cannot end with a hyphen."
  }
}

variable "visibility_timeout" {
  type        = number
  default     = null
  description = "The visibility timeout for the queue in seconds."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with lambda."
}

variable "enable_oldest_message_alarm" {
  type        = bool
  default     = true
  description = "If true, enables alarm when there oldest message exceed certain number of seconds."
}

variable "alarm_threshold_oldest_message" {
  type        = number
  default     = 3600
  description = "# of seconds of oldest messages that will trigger alarm."
}

variable "enable_num_msg_sent_alarm" {
  type        = bool
  default     = false
  description = "If true, enables alarm when there oldest message exceed certain number of seconds."
}

variable "alarm_threshold_num_msg_sent" {
  type        = number
  default     = 0
  description = "# of seconds of oldest messages that will trigger alarm."
}

variable "alarm_topic_arns" {
  type        = list(string)
  default     = []
  description = "Action for Alarm state (SNS arn)"
}

variable "ok_topic_arns" {
  type        = list(string)
  default     = []
  description = "Action for OK state of Alarm (SNS arn)"
}

variable "redrive_policy_json" {
  type        = string
  default     = null
  description = <<-EOT
    The JSON-encoded policy to set up the Dead Letter Queue. For more details, see https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/SQSDeadLetterQueue.html."

    Note: when specifying `maxReceiveCount`, you must specify it as an integer (`5`), and not a string (`"5"`).
  EOT
}

locals {
  tags = merge(var.tags, { "ops/module" = "aws/sqs-queue", Name = var.name })
}

