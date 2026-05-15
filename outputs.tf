output "agent_space_id" {
  description = "ID of the DevOps Agent Space"
  value       = awscc_devopsagent_agent_space.this.id
}

output "agent_space_arn" {
  description = "ARN of the DevOps Agent Space — use this to scope the workload cross-account role trust policy"
  value       = awscc_devopsagent_agent_space.this.arn
}

output "agent_space_name" {
  description = "Name of the DevOps Agent Space"
  value       = awscc_devopsagent_agent_space.this.name
}

output "agentspace_role_arn" {
  description = "ARN of the DevOps AgentSpace IAM role"
  value       = aws_iam_role.agentspace.arn
}

output "operator_role_arn" {
  description = "ARN of the DevOps Operator App IAM role"
  value       = aws_iam_role.operator.arn
}