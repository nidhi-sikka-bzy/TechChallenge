output "subnet_id" {
  description = "List of IDs of subnet(s)"
  value       = [ for subnet in aws_subnet.this : subnet.id ]
}

output "subnet_arn" {
  description = "List of ARN(s) of subnet(s)"
  value       = [ for subnet in aws_subnet.this : subnet.arn ]
  
}

output "named_subnet_ids" {
  description = "Map of subnet names to subnet IDs"

  value = zipmap(
    [ for subnet in aws_subnet.this : subnet.tags.Name ],
    coalescelist(
      [ for subnet in aws_subnet.this : subnet.id ],
    )
  )
}
