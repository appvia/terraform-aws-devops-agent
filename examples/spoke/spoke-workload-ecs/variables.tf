variable "aws_region" {
  description = "AWS region for workload account resources. Scopes the permissions boundary to this region — the agent will only read ECS, CloudWatch, ECR, and networking resources here."
  type        = string
  default     = "eu-west-2"
}

variable "agent_space_arn" {
  description = "ARN of the AgentSpace from the hosting-account deployment. Captured from the agent_space_arn output after Phase 1."
  type        = string
}

variable "role_name" {
  description = "Name for the cross-account IAM role in this workload account."
  type        = string
  default     = "DevOpsAgentCrossAccountRole"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
