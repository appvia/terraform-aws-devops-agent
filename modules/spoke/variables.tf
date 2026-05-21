variable "agent_space_arn" {
  description = "ARN of the Agent Space from the hub module output. Scopes this role's trust policy to that specific Agent Space — no other Agent Space in the hosting account can assume it."
  type        = string
}

variable "role_name" {
  description = "Name for the cross-account IAM role created in this workload account."
  type        = string
  default     = "DevOpsAgentCrossAccountRole"
}

variable "permissions_boundary_arn" {
  description = "Optional ARN of a permissions boundary policy to attach to the cross-account role. See examples/spoke/ for EKS and ECS boundary policy examples."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
