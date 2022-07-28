# Output variables to be used in Terraform integration tests...

output "primary_region" {
  value       = var.AWS_REGION
  description = "Primary bucket AWS region."
}

output "EIP1_Primary" {
  value       = data.aws_eip.peip1.id
  description = "EIP1."
}

output "EIP2_Primary" {
  value       = data.aws_eip.peip2.id
  description = "EIP2."
}

output "secondary_region" {
  value       = var.Second_AWS_REGION
  description = "Secondary bucket AWS region."
}

output "EIP1_Secondary" {
  value       = data.aws_eip.seip1.id
  description = "EIP1 for second region."
}

output "EIP2_Secondary" {
  value       = data.aws_eip.seip2.id
  description = "EIP1 for second region."
}

output "globalaccelerator_ips" {
  description = "IPs of global accelerator"
  value = flatten(
    module.global-accelerator.globalaccelerator_ips
  )
}

output "globalaccelerator_id" {
  description = "ID of global accelerator"
  value = module.global-accelerator.globalaccelerator_id
}

output "globalaccelerator_dns" {
  description = "DNS name of global accelerator"
  value = module.global-accelerator.globalaccelerator_dns
}
