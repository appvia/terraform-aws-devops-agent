<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_agent_space_name"></a> [agent\_space\_name](#input\_agent\_space\_name) | Display name of the DevOps Agent Space (shown in console). Spaces are allowed. | `string` | n/a | yes |
| <a name="input_agent_space_description"></a> [agent\_space\_description](#input\_agent\_space\_description) | Description for the DevOps Agent Space. | `string` | `"AWS DevOps Agent Space"` | no |
| <a name="input_agentspace_region"></a> [agentspace\_region](#input\_agentspace\_region) | Region where the AgentSpace is created. Must be a supported region — eu-west-2 (London) is not supported. See module README for the full list. | `string` | `"eu-west-1"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for hosting account resources. IAM is global so this is cosmetic, but should match your primary region. | `string` | `"eu-west-2"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Short slug used in IAM role names — no spaces. Defaults to agent\_space\_name with spaces replaced by hyphens. | `string` | `""` | no |
| <a name="input_secondary_accounts"></a> [secondary\_accounts](#input\_secondary\_accounts) | Map of workload accounts to associate as secondary sources. Populate after Phase 1 once each spoke role ARN is known. | <pre>map(object({<br/>    account_id             = string<br/>    cross_account_role_arn = string<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_agent_space_arn"></a> [agent\_space\_arn](#output\_agent\_space\_arn) | ARN of the AgentSpace. Pass this to each workload account's spoke configuration as agent\_space\_arn. |
| <a name="output_agent_space_id"></a> [agent\_space\_id](#output\_agent\_space\_id) | ID of the AgentSpace. |
| <a name="output_agent_space_name"></a> [agent\_space\_name](#output\_agent\_space\_name) | Display name of the AgentSpace. |
| <a name="output_agentspace_role_arn"></a> [agentspace\_role\_arn](#output\_agentspace\_role\_arn) | ARN of the AgentSpace IAM role in the hosting account. |
| <a name="output_operator_role_arn"></a> [operator\_role\_arn](#output\_operator\_role\_arn) | ARN of the Operator App IAM role. Configure IAM Identity Center to allow operator portal access via this role. |
<!-- END_TF_DOCS -->