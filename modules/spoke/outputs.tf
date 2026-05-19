output "role_arn" {
  description = "ARN of the cross-account IAM role. Pass this to the hub module's secondary_accounts map as cross_account_role_arn."
  value       = aws_iam_role.devops_agent.arn
}

output "role_name" {
  description = "Name of the cross-account IAM role."
  value       = aws_iam_role.devops_agent.name
}

output "role_iam_id" {
  description = "IAM ID of the cross-account role. Needed when attaching inline policies directly."
  value       = aws_iam_role.devops_agent.id
}
