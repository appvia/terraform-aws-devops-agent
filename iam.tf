data "aws_caller_identity" "current" {}

locals {
  # Falls back to agent_space_name if var name_prefix not set; replaces spaces → hyphens for IAM name safety
  name_prefix = var.name_prefix != "" ? var.name_prefix : replace(var.agent_space_name, " ", "-")
}

# AgentSpace role — assumed by the aidevops service to index + monitor resources
resource "aws_iam_role" "agentspace" {
  name = "DevOpsAgentRole-AgentSpace-${local.name_prefix}"

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
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            # Wildcard allows any agentspace in this account (consistent with sample)
            "aws:SourceArn" = "arn:aws:aidevops:${var.agentspace_region}:${data.aws_caller_identity.current.account_id}:agentspace/*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "agentspace_access" {
  role       = aws_iam_role.agentspace.name
  policy_arn = "arn:aws:iam::aws:policy/AIDevOpsAgentAccessPolicy"
}

# The primary/hosting account is not a workload — explicitly deny all resource discovery
# so the agent cannot scan or index it, regardless of what AIDevOpsAgentAccessPolicy allows.
# Resource indexing and scanning is only intended for secondary (workload) accounts.
resource "aws_iam_role_policy" "agentspace_deny_primary_discovery" {
  name = "DenyPrimaryAccountDiscovery"
  role = aws_iam_role.agentspace.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyResourceExplorer"
        Effect = "Deny"
        Action = ["resource-explorer-2:*"]
        Resource = "*"
      },
      {
        Sid    = "DenyResourceTagDiscovery"
        Effect = "Deny"
        Action = [
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues"
        ]
        Resource = "*"
      }
    ]
  })
}

# Operator App role — assumed by aidevops to drive the webapp/operator interface
resource "aws_iam_role" "operator" {
  name = "DevOpsAgentRole-WebappAdmin-${local.name_prefix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "aidevops.amazonaws.com"
        }
        Action = ["sts:AssumeRole", "sts:TagSession"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:aidevops:${var.agentspace_region}:${data.aws_caller_identity.current.account_id}:agentspace/*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "operator_access" {
  role       = aws_iam_role.operator.name
  policy_arn = "arn:aws:iam::aws:policy/AIDevOpsOperatorAppAccessPolicy"
}
