<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_agent_space_arn"></a> [agent\_space\_arn](#input\_agent\_space\_arn) | ARN of the AgentSpace from the hosting-account deployment. Captured from the agent\_space\_arn output after Phase 1. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for workload account resources. | `string` | `"eu-west-2"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name for the cross-account IAM role in this workload account. | `string` | `"DevOpsAgentCrossAccountRole"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cross_account_role_arn"></a> [cross\_account\_role\_arn](#output\_cross\_account\_role\_arn) | ARN of the cross-account IAM role. Pass this to the hosting-account secondary\_accounts map. |
| <a name="output_cross_account_role_name"></a> [cross\_account\_role\_name](#output\_cross\_account\_role\_name) | Name of the cross-account IAM role. |
<!-- END_TF_DOCS -->