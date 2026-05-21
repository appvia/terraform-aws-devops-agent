# Wait for IAM propagation before creating the Agent Space
resource "time_sleep" "iam_propagation" {
  depends_on = [
    aws_iam_role.agentspace,
    aws_iam_role_policy_attachment.agentspace_access,
    aws_iam_role.operator,
    aws_iam_role_policy_attachment.operator_access,
  ]
  create_duration = "30s"
}

# Agent Space
resource "awscc_devopsagent_agent_space" "this" {
  name        = var.agent_space_name
  description = var.agent_space_description

  operator_app = {
    iam = {
      operator_app_role_arn = aws_iam_role.operator.arn
    }
  }

  # terraform expects set of objects for tags this awscc resource, but we want to allow users to provide a simple map in variable to make it re-usable
  tags = toset([
    for k, v in var.tags : {
      key   = k
      value = v
    }
  ])

  depends_on = [time_sleep.iam_propagation]
}

# Primary account association (hosting account as monitor)
resource "awscc_devopsagent_association" "primary" {
  agent_space_id = awscc_devopsagent_agent_space.this.id
  service_id     = "aws"

  configuration = {
    aws = {
      assumable_role_arn = aws_iam_role.agentspace.arn
      account_id         = data.aws_caller_identity.current.account_id
      account_type       = "monitor"
      resources          = []
    }
  }

  depends_on = [awscc_devopsagent_agent_space.this]
}

/*
Secondary (workload) account associations — one per entry in var.secondary_accounts.
Workflow: first apply with an empty map, capture agent_space_arn output, ensure each
workload's cross-account role trust policy references the real agentspace ARN, then
populate the map and apply again.
*/
resource "awscc_devopsagent_association" "workload" {
  for_each       = var.secondary_accounts
  agent_space_id = awscc_devopsagent_agent_space.this.id
  service_id     = "aws"

  configuration = {
    source_aws = {
      assumable_role_arn = each.value.cross_account_role_arn
      account_id         = each.value.account_id
      account_type       = "source"
    }
  }

  depends_on = [awscc_devopsagent_association.primary]
}