variable "AWS_REGION" {
  type = string
}

variable "Client_REGION" {
  type = string
}

variable "secret_prefix" {
  type        = string
  description = "Secret prefix used for sftp-server creation. This value is also used for sftp user(AWS Secrets Manager) creation. (e.g. secret_prefix = 'nonprod', AWS secret for user will be 'nonprod/sftpusername')"
}

variable "sftp_server_id" {
  type        = string
  description = "Transfer Family Server that created"
}

variable "password" {
  type        = string
  description = "Random Password"
}

variable "is_admin" {
  type        = bool
  default     = true
  description = "Is this a admin user"
}

variable "client_name" {
  type        = string
  description = "SFTP client name"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name that created as part of the transfer family"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags associated with the resource."
  default     = {}
}

locals {
  name = "${var.secret_prefix}-${var.Client_REGION}-${var.client_name}"
  tags = merge({ "ops/module" = "aws/transfer-family/sftp-user" }, var.tags)
}
