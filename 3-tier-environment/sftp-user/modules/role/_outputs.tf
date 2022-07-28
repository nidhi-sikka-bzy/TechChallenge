output "id" {
  value       = aws_iam_role.role.id
  description = "The name of the role."
}

output "unique_id" {
  value       = aws_iam_role.role.unique_id
  description = "The stable and unique string identifying the role."
}

output "arn" {
  value       = aws_iam_role.role.arn
  description = "The Amazon Resource Name (ARN) of the role."
}

output "max_session_duration" {
  value       = aws_iam_role.role.max_session_duration
  description = "The maximum duration (in seconds) that a role session is valid."
}
