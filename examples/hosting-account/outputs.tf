output "agent_space_id" {
  description = "ID of the AgentSpace."
  value       = module.devops_agent.agent_space_id
}

output "agent_space_arn" {
  description = "ARN of the AgentSpace. Pass this to each workload account's spoke configuration as agent_space_arn."
  value       = module.devops_agent.agent_space_arn
}

output "agent_space_name" {
  description = "Display name of the AgentSpace."
  value       = module.devops_agent.agent_space_name
}

output "agentspace_role_arn" {
  description = "ARN of the AgentSpace IAM role in the hosting account."
  value       = module.devops_agent.agentspace_role_arn
}

output "operator_role_arn" {
  description = "ARN of the Operator App IAM role. Configure IAM Identity Center to allow operator portal access via this role."
  value       = module.devops_agent.operator_role_arn
}
