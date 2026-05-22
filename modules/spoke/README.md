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
## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_agent_space_arn"></a> [agent\_space\_arn](#input\_agent\_space\_arn) | ARN of the Agent Space from the hub module output. Scopes this role's trust policy to that specific Agent Space — no other Agent Space in the hosting account can assume it. | `string` | n/a | yes |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | Optional ARN of a permissions boundary policy to attach to the cross-account role. See examples/spoke/ for EKS and ECS boundary policy examples. | `string` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name for the cross-account IAM role created in this workload account. | `string` | `"DevOpsAgentCrossAccountRole"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the cross-account IAM role. Pass this to the hub module's secondary\_accounts map as cross\_account\_role\_arn. |
| <a name="output_role_iam_id"></a> [role\_iam\_id](#output\_role\_iam\_id) | IAM ID of the cross-account role. Needed when attaching inline policies directly. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the cross-account IAM role. |
<!-- END_TF_DOCS -->
