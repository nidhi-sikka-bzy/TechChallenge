output "passed_bucket_name" {
  value = local.bucket
}

/*output "primary_bucket_name" {
  value = data.terraform_remote_state.bucket.outputs.primary_bucket_id
}

output "secondary_bucket_name" {
  value = data.terraform_remote_state.bucket.outputs.secondary_bucket_id
}*/


