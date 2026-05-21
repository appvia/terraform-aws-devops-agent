# spoke

Deploys the AWS DevOps Agent cross-account IAM role in a workload account.

This submodule is called from a **separate Terraform configuration targeting the workload account** — not from the same configuration as the root module. The root module runs in the hosting account and creates the AgentSpace; this module runs in each workload account and creates the IAM role that the AgentSpace assumes.

## Usage

**Step 1 — Run the root module** in the hosting account and capture the `agent_space_arn` output.

**Step 2 — Run this module** in the workload account, passing that ARN:

```hcl
module "spoke" {
  source = "appvia/devops-agent/aws//modules/spoke"

  agent_space_arn = "<agent_space_arn from step 1>"
  role_name       = "DevOpsAgentCrossAccountRole"
  tags            = { Environment = "production" }
}
```

**Step 3 — Update the root module** `secondary_accounts` map with the role ARN from `module.spoke.role_arn` and re-apply the hosting account configuration.

## Permissions Boundary (optional)

For accounts running multiple workloads or environments, attach a permissions boundary to restrict the agent to a specific region and service:

```hcl
module "spoke" {
  source = "appvia/devops-agent/aws//modules/spoke"

  agent_space_arn          = "<agent_space_arn>"
  permissions_boundary_arn = aws_iam_policy.devops_agent_boundary.arn
}
```

See `examples/spoke/spoke-workload-eks/` and `examples/spoke/spoke-workload-ecs/` for complete boundary policy examples.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
