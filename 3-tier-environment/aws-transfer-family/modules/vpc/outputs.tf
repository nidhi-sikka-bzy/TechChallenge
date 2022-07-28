output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.this.default_security_group_id
}