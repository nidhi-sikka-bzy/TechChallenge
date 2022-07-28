output "globalaccelerator_ips" {
  description = "IPs of global accelerator"
  value = flatten(
    aws_globalaccelerator_accelerator.this.*.ip_sets.0.ip_addresses,
  )
}

output "globalaccelerator_id" {
  description = "ID of global accelerator"
  value = aws_globalaccelerator_accelerator.this.id
}

output "globalaccelerator_dns" {
  description = "DNS name of global accelerator"
  value = aws_globalaccelerator_accelerator.this.dns_name
}
