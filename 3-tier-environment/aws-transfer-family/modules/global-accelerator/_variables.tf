variable "ga_name" {
  type        = string
  #default     = ""
  description = "The name of global accelerator."
}

variable "zone_name" {
  type        = string
  default     = null
  description = "[Optional] Route53 zone name."
}

variable "dns_names" {
  type        = list(string)
  default     = ["."]
  description = "[Optional] DNS name of the global accelerator to be added to route53 zone."
}

variable "log_bucket" {
  type        = string
  description = "The name of the S3 bucket where access logs should be stored."
  default     = ""
}

variable "endpoint_region" {
  type = object({
    primary   = string
    secondary = string
  })
  description = "AWS Region where global accelerator endpoints will be configured. If needed please specify a secondary region also."
  default = {
    "primary"   = ""
    "secondary" = ""
  }
}
variable "alb_endpoint" {
  type = object({
    primary   = string
    secondary = string
  })
  description = "ALB arn to be add to global accelerator endpoints."
  default = {
    "primary"   = ""
    "secondary" = ""
  }
}


variable "enable_client_affinity" {
  type        = bool
  default     = true
  description = "[Optional] A value indicating whether or not we want to enable client affinity on the global accelerator listener to SOURCE_IP."
}

variable "health_check_path" {
  type = object({
    primary   = string
    secondary = string
  })
  description = "[Optional] Path representing the destination for health check targets associated ALB endpoints."
  default = {
    "primary"   = "/"
    "secondary" = "/"
  }

  validation {
    condition     = can(regex("^\\/[[:alnum:]/]*$", var.health_check_path["primary"])) && can(regex("^\\/[[:alnum:]/]*$", var.health_check_path["secondary"]))
    error_message = "The healthcheck path is not correct. Should start with backslash followed by alphanumeric or backslash."
  }
}

variable "threshold_count" {
  type = object({
    primary   = string
    secondary = string
  })
  description = "[Optional] Number of concecutive health checks to set the state of a healthy endpoint to unhealthy or vice versa."
  default = {
    "primary"   = "3"
    "secondary" = "3"
  }
}

variable "traffic_dial_percentage" {
  type = object({
    primary   = string
    secondary = string
  })
  description = "[Optional] Percentage of traffic to send to an AWS Region."
  default = {
    "primary"   = "100"
    "secondary" = "100"
  }
}

variable "endpoint_weight" {
  type = object({
    primary   = string
    secondary = string
  })
  description = "[Optional] Weight associated with ALB endpoints"
  default = {
    "primary"   = "100"
    "secondary" = "100"
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags associated with the resource."
}
variable "health_check_port" {
  type        = string
  default     = null
  description = "Port to check health of listener."
}

variable "sftp_from_port" {
  type        = string
  default     = null
  description = "Starting range for listener port."
}

variable "sftp_to_port" {
  type        = string
  default     = null
  description = "Ending range for listener port."
}

variable "listeners_list" {
  type        = string
  default     = "sftp"
  description = "Comma separated List if more than one listener is required for GloablaAccelerator ie. [https,sftp]"
}

variable "server_endpoint" {
  type = object({
    primary   = list(string)
    secondary = list(string)
  })
  description = "EIP/ALB ARN to be add to global accelerator endpoints. If necessary please specify an EIP/ALB arn in a second region also. Leave secondary empty to set an endpoint in primary region only."
  default = {
    "primary"   = [""]
    "secondary" = [""]
  }
}

locals {

  domain             = var.zone_name != null ? trim(data.aws_route53_zone.zone[0].name, ".") : ""
  dns_names          = toset(var.dns_names)
  dns_name           = var.dns_names[0] == "." ? "" : var.dns_names[0]
  qualified_domain   = trim(lower(replace("${local.dns_name}-${local.domain}", "/[[:punct:]]/", "-")), "-")
  zone_id            = var.zone_name != null ? data.aws_route53_zone.zone[0].zone_id : ""
  name               = var.ga_name == null ? local.qualified_domain : var.ga_name
  qualified_name     = trim(substr(local.name, 0, min(length(local.name), 32)), "-")
  client_affinity    = var.enable_client_affinity == true ? "SOURCE_IP" : "NONE"
  tags               = merge(var.tags, { "ops/module" = "aws/global-accelerator" })
  from_port          = var.sftp_from_port == null ? 22 : var.sftp_from_port
  to_port            = var.sftp_to_port == null ? 22 : var.sftp_to_port
  health_check_port  = var.health_check_path == null ? 22 : var.health_check_port
  listeners          = split(",", var.listeners_list)
  ga_primary_endpoint_configurations =[ 
    { endpoint_id = var.server_endpoint["primary"][0] },
    { endpoint_id = var.server_endpoint["primary"][1] }
  ]
  ga_secondary_endpoint_configurations =[ 
    { endpoint_id = var.server_endpoint["secondary"][0] },
    { endpoint_id = var.server_endpoint["secondary"][1] }
  ] 
}

