data "aws_iam_policy" "devops_agent_access" {
  name = "AIDevOpsAgentAccessPolicy"
}

locals {
  # Extract the hosting account ID from the AgentSpace ARN for SourceAccount condition.
  # arn:aws:aidevops:<region>:<account-id>:agentspace/<id>
  hub_account_id = regex("arn:aws:aidevops:[^:]+:([0-9]+):agentspace/.*", var.agent_space_arn)[0]
}

resource "aws_iam_role" "devops_agent" {
  name                 = var.role_name
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "aidevops.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          # ArnEquals pins to the exact AgentSpace — no wildcard unlike hub roles.
          # SourceAccount is defense-in-depth; ArnEquals already implicitly validates account.
          ArnEquals = {
            "aws:SourceArn" = var.agent_space_arn
          }
          StringEquals = {
            "aws:SourceAccount" = local.hub_account_id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "devops_agent_access" {
  role       = aws_iam_role.devops_agent.name
  policy_arn = data.aws_iam_policy.devops_agent_access.arn
}

# Allows the agent to create the Resource Explorer service-linked role
# so it can index resources across the workload account for topology mapping.
resource "aws_iam_role_policy" "resource_explorer_slr" {
  name = "${var.role_name}-ResourceExplorerSLR"
  role = aws_iam_role.devops_agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCreateResourceExplorerSLR"
        Effect   = "Allow"
        Action   = "iam:CreateServiceLinkedRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "resource-explorer-2.amazonaws.com"
          }
        }
      }
    ]
  })
}
