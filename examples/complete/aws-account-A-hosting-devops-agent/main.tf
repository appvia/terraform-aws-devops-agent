#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

#####################################################################################
# Hosting Account — AgentSpace Deployment
#
# This example deploys an AgentSpace in the dedicated hosting (hub) account.
# Run this first. After applying, use the agent_space_arn output to configure
# the cross-account role in each workload account (see examples/spoke/).
#
# PHASE 1: Apply with secondary_accounts = {} (default). Capture agent_space_arn.
# PHASE 2: Populate secondary_accounts with spoke role ARNs and re-apply.
#####################################################################################

module "devops_agent" {
  source  = "appvia/devops-agent/aws"
  version = "0.1.1"

  agent_space_name        = var.agent_space_name
  name_prefix             = var.name_prefix
  agent_space_description = var.agent_space_description
  agentspace_region       = var.agentspace_region

  # Phase 1: leave empty — apply and capture the agent_space_arn output.
  # Phase 2: add an entry per workload account once the spoke role ARN is known.
  secondary_accounts = var.secondary_accounts

  tags = var.tags
}
