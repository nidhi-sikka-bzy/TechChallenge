# Output variables to be used in Terraform integration tests...

output "primary_region" {
  value       = var.AWS_REGION
  description = "Primary bucket AWS region."
}

output "primary_bucket_arn" {
  value       = module.bucket_primary.arn
  description = "Primary bucket ARN."
}

output "primary_bucket_id" {
  value       = module.bucket_primary.id
  description = "Primary bucket ID."
}

output "secondary_region" {
  value       = var.Second_AWS_REGION
  description = "Secondary bucket AWS region."
}

output "secondary_bucket_arn" {
  value       = module.bucket_secondary.arn
  description = "Secondary bucket ARN."
}

output "secondary_bucket_id" {
  value       = module.bucket_secondary.id
  description = "Secondary bucket ID."
}
