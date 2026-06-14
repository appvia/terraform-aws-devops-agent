variable "agent_space_name" {
  description = "Display name of the DevOps Agent Space (shown in the console — spaces allowed)"
  type        = string
}

variable "name_prefix" {
  description = "Short slug used in IAM role names — no spaces or special chars. Defaults to agent_space_name with spaces replaced by hyphens if not set."
  type        = string
  default     = ""
  validation {
    condition     = length(var.name_prefix) <= 35
    error_message = "name_prefix must be 35 characters or fewer — IAM role names are limited to 64 chars and the longest prefix 'DevOpsAgentRole-WebappAdmin-' is 29 chars."
  }
}

variable "agent_space_description" {
  description = "Description for the DevOps Agent Space"
  type        = string
  default     = "AWS DevOps Agent Space"
}

variable "agentspace_region" {
  description = "AWS region where the Agent Space is deployed. Supported regions: us-east-1, us-west-2, eu-west-1, eu-west-2, eu-central-1, ap-southeast-2, ap-northeast-1."
  type        = string
  validation {
    condition     = contains(["us-east-1", "us-west-2", "eu-west-1", "eu-west-2", "eu-central-1", "ap-southeast-2", "ap-northeast-1"], var.agentspace_region)
    error_message = "Agent Space can only be deployed in us-east-1, us-west-2, eu-west-1, eu-west-2, eu-central-1, ap-southeast-2, or ap-northeast-1."
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