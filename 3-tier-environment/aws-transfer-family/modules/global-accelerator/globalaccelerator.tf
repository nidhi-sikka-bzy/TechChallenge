resource "aws_globalaccelerator_accelerator" "this" {
  name            = local.qualified_name
  ip_address_type = "IPV4"
  enabled         = true

  tags = merge(local.tags, { "ops/module-primary" = "aws/global-accelerator" })
}

resource "aws_globalaccelerator_listener" "https" {
  count           = contains(local.listeners, "https") ? 1 : 0
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = local.client_affinity
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "ga_https_endpoint_primary" {
  count                   = contains(local.listeners, "https") ? 1 : 0
  listener_arn            = aws_globalaccelerator_listener.https[0].id
  endpoint_group_region   = var.endpoint_region["primary"]
  health_check_protocol   = "TCP"
  health_check_port       = 443
  health_check_path       = var.health_check_path["primary"]
  threshold_count         = var.threshold_count["primary"]
  traffic_dial_percentage = var.traffic_dial_percentage["primary"]

  endpoint_configuration {
    endpoint_id                    = var.alb_endpoint["primary"]
    weight                         = var.endpoint_weight["primary"]
    client_ip_preservation_enabled = "true"
  }

  lifecycle {
    ignore_changes = [
      health_check_path,
    ]
  }
}


resource "aws_globalaccelerator_endpoint_group" "ga_https_endpoint_secondary" {
  count                   = length(var.alb_endpoint["secondary"]) > 0 ? 1 : 0
  listener_arn            = aws_globalaccelerator_listener.https[0].id
  endpoint_group_region   = var.endpoint_region["secondary"]
  health_check_protocol   = "TCP"
  health_check_port       = 443
  health_check_path       = var.health_check_path["secondary"]
  threshold_count         = var.threshold_count["secondary"]
  traffic_dial_percentage = var.traffic_dial_percentage["secondary"]
  endpoint_configuration {
    endpoint_id                    = var.alb_endpoint["secondary"]
    weight                         = var.endpoint_weight["secondary"]
    client_ip_preservation_enabled = "true"
  }

  lifecycle {
    ignore_changes = [
      health_check_path,
    ]
  }
}

resource "aws_globalaccelerator_listener" "sftp" {
  count           = contains(local.listeners, "sftp") ? 1 : 0
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = local.client_affinity
  protocol        = "TCP"

  port_range {
    from_port = local.from_port
    to_port   = local.to_port
  }
}

resource "aws_globalaccelerator_endpoint_group" "ga_sftp_endpoint_primary" {
  count                   = length(var.server_endpoint["primary"][0]) > 0 ? 1 : 0
  listener_arn            = aws_globalaccelerator_listener.sftp[0].id
  endpoint_group_region   = var.endpoint_region["primary"]
  health_check_protocol   = "TCP"
  health_check_port       = local.health_check_port
  threshold_count         = var.threshold_count["primary"]
  traffic_dial_percentage = var.traffic_dial_percentage["primary"]
  
  dynamic "endpoint_configuration" {
    for_each = local.ga_primary_endpoint_configurations

    content {
      endpoint_id                    = endpoint_configuration.value.endpoint_id
      client_ip_preservation_enabled = false
      weight                         = "100"
    }
  }
}

resource "aws_globalaccelerator_endpoint_group" "ga_sftp_endpoint_secondary" {
  count                   = length(var.server_endpoint["secondary"][0]) > 0 ? 1 : 0
  listener_arn            = aws_globalaccelerator_listener.sftp[0].id
  endpoint_group_region   = var.endpoint_region["secondary"]
  health_check_protocol   = "TCP"
  health_check_port       = local.health_check_port
  threshold_count         = var.threshold_count["secondary"]
  traffic_dial_percentage = var.traffic_dial_percentage["secondary"]

  dynamic "endpoint_configuration" {
    for_each = local.ga_secondary_endpoint_configurations

    content {
      endpoint_id                    = endpoint_configuration.value.endpoint_id
      client_ip_preservation_enabled = false
      weight                         = "100"
    }
  }
}

resource "aws_route53_record" "globalaccelerator" {
  for_each = local.zone_id != "" ? local.dns_names : []
  zone_id  = local.zone_id
  name     = each.key
  type     = "A"
  ttl      = "300"
  records  = aws_globalaccelerator_accelerator.this.ip_sets[0].ip_addresses
}

data "aws_route53_zone" "zone" {
  count = var.zone_name != null ? 1 : 0
  name  = var.zone_name
}
