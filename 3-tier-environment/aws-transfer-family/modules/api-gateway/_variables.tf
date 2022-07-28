data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

## Required###
variable "name" {
  type        = string
  description = "Name for the API gateway. "
}

variable "stage_name" {
  type        = string
  #default     = "dev"
  description = "Deployment stage name"
}

variable "open_api_file" {
  type        = string
  description = "File path/name of the swagger/open api file"
}


variable "api_vars" {
  type        = map(string)
  description = "Variables to be provided for the api template"
}

variable "uri" {
  type        = string
  description = "Lambda invoke arn"
}

variable "lambda_name" {
  type        = string
  description = "Lambda function name"
}

###Optional
variable "description" {
  type        = string
  default     = ""
  description = "Description for the API Gateway"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with the API Gateway."
}

variable "enable_xray" {
  type        = bool
  default     = true
  description = "Enable xray tracing"
}

variable "enable_metrics" {
  type        = bool
  default     = true
  description = "Enable detailed metrics per api"
}

variable "log_level" {
  #OFF, ERROR, INFO
  type        = string
  default     = "INFO"
  description = "Log level - OFF, INFO, ERROR"
}

variable "log_retention_days" {
  type        = number
  default     = 14
  description = "Number of days to retain logs"
}

variable "enable_data_trace" {
  type        = bool
  default     = false
  description = "Log full requests/responses data"
}

variable "enable_caching" {
  type        = bool
  default     = false
  description = "Enable caching of response"
}

variable "throttling_burst_limit" {
  type        = number
  default     = 5000
  description = "Throttling Burst limit"
}

variable "throttling_rate_limit" {
  type        = number
  default     = 10000
  description = "Throttling Rate limit"
}

variable "enable_throttle_alarm" {
  type        = bool
  default     = false
  description = "Enable Alarm for Throttled requests"
}

variable "throttleAlarmThreshold" {
  type        = number
  default     = 5
  description = "Percent of throttled request to cause alarm"
}

variable "alarmThreshold5xx" {
  type        = number
  default     = 0.05
  description = "Percent of request with 5XX error to cause alarm"
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

###Locals
locals {
  tags = merge(var.tags, { "ops/module" = "aws/api-gateway" })
}
