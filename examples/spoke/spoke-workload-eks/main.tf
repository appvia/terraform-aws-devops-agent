#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

#####################################################################################
# Spoke — EKS Workload with Permissions Boundary
#
# Deploys the DevOps Agent cross-account IAM role with an EKS permissions boundary.
# The boundary restricts the agent to read EKS, CloudWatch, ECR, ALB, VPC, and
# Resource Explorer resources in the specified region only.
#
# Prerequisites:
#   1. Run examples/hosting-account and capture the agent_space_arn output.
#   2. Set agent_space_arn in terraform.tfvars to that value.
#   3. Apply this configuration in the workload account.
#   4. Pass the cross_account_role_arn output back to the hosting-account
#      secondary_accounts map and re-apply the hub (Phase 2).
#   5. For kubectl read access (describe pods, events, logs), create an EKS access
#      entry for the cross_account_role_arn on each cluster. The boundary grants
#      the IAM permission eks:AccessKubernetesApi but the cluster itself must also
#      allow the role via an access entry — this is not managed by this module.
#####################################################################################

module "spoke" {
  source = "appvia/devops-agent/aws//modules/spoke"

  agent_space_arn          = var.agent_space_arn
  role_name                = var.role_name
  permissions_boundary_arn = aws_iam_policy.devops_agent_boundary.arn

  tags = var.tags
}
