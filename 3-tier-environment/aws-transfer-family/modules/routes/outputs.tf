output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = aws_route_table.public.*.id
}
