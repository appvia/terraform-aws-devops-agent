data "aws_iam_policy" "devops_agent_access" {
  name = "AIDevOpsAgentAccessPolicy"
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
          # ArnEquals pins account + Agent Space — no wildcard,
          # unlike the hub roles which use agentspace/*.
          ArnEquals = {
            "aws:SourceArn" = var.agent_space_arn
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
