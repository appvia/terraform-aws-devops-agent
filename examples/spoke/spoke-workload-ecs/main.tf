#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

#####################################################################################
# Spoke — ECS/Fargate Workload with Permissions Boundary
#
# Deploys the DevOps Agent cross-account IAM role with an ECS permissions boundary.
# The boundary restricts the agent to read ECS, Fargate, Cloud Map (Service Connect),
# CloudWatch, ECR, ALB, VPC, and Resource Explorer resources in the region only.
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
  version = "v1.0.0"

  agent_space_arn          = var.agent_space_arn
  role_name                = var.role_name
  permissions_boundary_arn = aws_iam_policy.devops_agent_boundary.arn

  tags = var.tags
}
