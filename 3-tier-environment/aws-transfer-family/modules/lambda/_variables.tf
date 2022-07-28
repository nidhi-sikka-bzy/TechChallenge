variable "name" {
  type        = string
  description = "The name of the Lambda function."

  validation {
    condition     = can(regex("^[[:alpha:]]+[[:alnum:]-]+[[:alnum:]]+$", var.name))
    error_message = "The name must contain only letters, numbers, or hypen (-). It must start with a letter and cannot end with a hyphen."
  }
}

variable "package_type" {
  type        = string
  default     = "Zip"
  description = "The Lambda deployment package type. Valid values are Zip and Image. Defaults to Zip."
}

variable "source_dir" {
  type        = string
  default     = null
  description = "Package entire contents of this directory into the Lambda archive."
}

variable "image_uri" {
  type        = string
  default     = null
  description = "The ECR image URI containing the function's deployment package."
}

variable "image_entry_point" {
  type        = list(string)
  default     = null
  description = "The ENTRYPOINT for the docker image."
}

variable "image_command" {
  type        = list(string)
  default     = null
  description = "The CMD for the docker image"
}

variable "image_working_directory" {
  type        = string
  default     = null
  description = "The working directory for the docker image."
}

variable "handler" {
  type        = string
  default     = null
  description = "The function entrypoint in your code."
}

variable "runtime" {
  type        = string
  default     = null
  description = "The runtime for lambda ie python3.8, nodejs12.x, go1.x, dotnetcore3.1, java11."
}

variable "env" {
  type        = map(string)
  default     = null
  description = "A map that defines environment variables for the Lambda function."
}

variable "timeout" {
  type        = number
  default     = 60
  description = "The amount of time your Lambda Function has to run in seconds. Defaults to 60."
}

variable "memory_size" {
  type        = number
  default     = null
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128."
}

variable "reserved_concurrent_executions" {
  type        = number
  default     = null
  description = "The amount of reserved concurrent executions. 0 disables lambda and -1 removes any limit."
}

variable "policy_documents" {
  type        = list(string)
  default     = []
  description = "List of IAM Policy Documents for Lambda role."
}

variable "policy_arns" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
  description = "List of IAM Policy ARNs for Lambda role.  *** Use only pre-existing policies ***"
}

variable "layers" {
  type        = list(string)
  default     = []
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda function."
}

variable "vpc_name" {
  type        = string
  default     = null
  description = "The name of the VPC in which the instance should be deployed."
}

variable "egress_security_groups" {
  type        = list(string)
  default     = []
  description = "A list of egress security group IDs to associate with."
}

variable "maximum_event_age_in_seconds" {
  type        = number
  default     = null
  description = "Maximum age of a request that Lambda sends to a function for processing in seconds."
}

variable "maximum_retry_attempts" {
  type        = number
  default     = null
  description = "Maximum number of times to retry when the function returns an error."
}

variable "on_success_destination" {
  type        = string
  default     = null
  description = "ARN of destination resource - SNS, Lambda or SQS."
}

variable "bucket" {
  type        = string
  default     = null
  description = "The S3 bucket location for the function's deployment package."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with Lambda."
}

variable "enable_active_tracing" {
  type        = bool
  default     = false
  description = "If true, enables active tracing. The default false sets it to pass through mode."
}

variable "enable_throttles_alarm" {
  type        = bool
  default     = false
  description = "If true, enables throttle alarm."
}

variable "enable_dead_letter_error_alarm" {
  type        = bool
  default     = false
  description = "If true, enables alarm when there are errors putting to the dead letter queue."
}

variable "alarm_threshold_throttles" {
  type        = number
  default     = 5
  description = "Percent of throttles errors that will trigger alarm."
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

locals {
  is_zip_package          = var.package_type == "Zip"
  is_image_package        = var.package_type == "Image"
  has_image_config        = toset(var.image_entry_point == null && var.image_command == null && var.image_working_directory == null ? [] : ["true"])
  has_env                 = toset(var.env == null ? [] : ["true"])
  has_success_destination = toset(var.on_success_destination == null ? [] : ["true"])
  has_vpc_name            = toset(var.vpc_name == null ? [] : ["true"])
  vpc_name                = var.vpc_name == null ? null : trim(lower(replace(var.vpc_name, "/[[:punct:]]|[[:space:]]/", "-")), "-")
  tags                    = merge(var.tags, { "ops/module" = "aws/lambda", Name = var.name })
}
