variable "agent_space_name" {
  description = "Display name of the DevOps Agent Space (shown in the console — spaces allowed)"
  type        = string
}

variable "name_prefix" {
  description = "Short slug used in IAM role names — no spaces or special chars (defaults to agent_space_name if not set)"
  type        = string
  default     = ""
}

variable "agent_space_description" {
  description = "Description for the DevOps Agent Space"
  type        = string
  default     = "AWS DevOps Agent Space"
}

variable "agentspace_region" {
  description = "AWS region where the agentspace is deployed (aidevops is in specific regions only)"
  type        = string
  validation {
    condition     = contains(["us-east-1", "us-west-2", "eu-west-1", "eu-west-2"], var.agentspace_region)
    error_message = "Agent Space can only be deployed in us-east-1, us-west-2, eu-west-1, or eu-west-2 currently"
  }
}

variable "secondary_accounts" {
  description = "Map of secondary accounts to associate as secondary sources. Key is a short label (used in resource names). Leave empty on first apply; populate after capturing agent_space_arn."
  type = map(object({
    account_id             = string
    cross_account_role_arn = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}