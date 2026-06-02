#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

#####################################################################################
# Spoke — Basic Cross-Account Role
#
# Deploys the DevOps Agent cross-account IAM role in a workload account with no
# permissions boundary. Use this for single-environment accounts where all
# resources in the account belong to one workload.
#
# Prerequisites:
#   1. Run examples/hosting-account and capture the agent_space_arn output.
#   2. Set agent_space_arn in terraform.tfvars to that value.
#   3. Apply this configuration in the workload account.
#   4. Pass the cross_account_role_arn output back to the hosting-account
#      secondary_accounts map and re-apply the hub (Phase 2).
#####################################################################################

module "spoke" {
  source  = "appvia/devops-agent/aws//modules/spoke"
  version = "~> 0.1"

  agent_space_arn = var.agent_space_arn
  role_name       = var.role_name

  tags = var.tags
}
