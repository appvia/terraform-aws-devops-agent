output "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role. Pass this to the hosting-account secondary_accounts map."
  value       = module.spoke.role_arn
}

output "cross_account_role_name" {
  description = "Name of the cross-account IAM role."
  value       = module.spoke.role_name
}

output "permissions_boundary_arn" {
  description = "ARN of the ECS permissions boundary policy attached to the cross-account role."
  value       = aws_iam_policy.devops_agent_boundary.arn
}
