output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value = module.vpc.default_security_group_id
}

output "extra_security_group_id" {
  description = "The ID of the security group created"
  value = aws_security_group.allow_all.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.internet_gateway.internet_gateway_id
}

output "internet_gateway_arn" {
  description = "The ARN of the Internet Gateway"
  value       = module.internet_gateway.internet_gateway_arn
}

output "internet_gateway_owner_id" {
  description = "The owner_id of the Internet Gateway"
  value       = module.internet_gateway.internet_gateway_owner_id
}

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = module.public_routes.public_route_table_ids
}

output "public_subnets" {
  description = "List of ARN(s) of subnet(s)"
  value       = module.public_subnets.subnet_id
}

output "named_public_subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value = module.public_subnets.named_subnet_ids
}

output "eip_id1" {
  description = "List of IDs of elastic IPs"
  value       = module.elastic_ip1.eip_ids
}

output "eip_id2" {
  description = "List of IDs of elastic IPs"
  value       = module.elastic_ip2.eip_ids
}

output "subnet1" {
  description = "List of IDs of elastic IPs"
  value = "${element(module.public_subnets.subnet_id, 0)}"
}

output "subnet2" {
  description = "List of IDs of elastic IPs"
  value = "${element(module.public_subnets.subnet_id, 1)}"
}

output "eni1_id" {
  value = data.aws_network_interfaces.eni_id1.ids
}

output "eni2_id" {
  value = data.aws_network_interfaces.eni_id2.ids
}

output "transfer-server-details" {
  value       = module.transfer-server
  description = "sftp server details."
}