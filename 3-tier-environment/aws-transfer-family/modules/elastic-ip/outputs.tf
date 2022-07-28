output "eip_ids" {
  description = "List of IDs of elastic IPs"
  value       = aws_eip.this.*.id
}

output "eip_private_ips" {
  description = "List of private IP(s) for elastic IPs"
  value       = aws_eip.this.*.private_ip
}

output "eip_public_ips" {
  description = "List of public IP(s) for elastic IPs"
  value       = aws_eip.this.*.public_ip
}