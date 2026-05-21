variable "aws_region" {
  description = "AWS region for hosting account resources. IAM is global so this is cosmetic, but should match your primary region."
  type        = string
  default     = "eu-west-2"
}

variable "agentspace_region" {
  description = "Region where the AgentSpace is created. Must be a supported region — eu-west-2 (London) is not supported. See module README for the full list."
  type        = string
  default     = "eu-west-1"
}

variable "agent_space_name" {
  description = "Display name of the DevOps Agent Space (shown in console). Spaces are allowed."
  type        = string
}

variable "name_prefix" {
  description = "Short slug used in IAM role names — no spaces. Defaults to agent_space_name with spaces replaced by hyphens."
  type        = string
  default     = ""
}

variable "agent_space_description" {
  description = "Description for the DevOps Agent Space."
  type        = string
  default     = "AWS DevOps Agent Space"
}

variable "secondary_accounts" {
  description = "Map of workload accounts to associate as secondary sources. Populate after Phase 1 once each spoke role ARN is known."
  type = map(object({
    account_id             = string
    cross_account_role_arn = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
