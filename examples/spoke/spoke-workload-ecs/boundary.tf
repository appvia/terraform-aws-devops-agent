#####################################################################################
# ECS/Fargate Permissions Boundary
#
# Scopes the DevOps Agent to ECS, Fargate, Cloud Map (Service Connect), and
# supporting services in a single region.
# Effective permissions = AIDevOpsAgentAccessPolicy ∩ this boundary.
#
# Scoping strategy (mirrors the EKS boundary pattern):
#   - Regional condition (aws:RequestedRegion) applied throughout.
#   - ECS list/describe operations are account-wide in IAM — tag-based conditions
#     silently deny on these actions; regional scoping is the reliable mechanism.
#   - CloudWatch Logs and ECR are scoped by region-qualified ARN wildcard.
#   - Cloud Map (servicediscovery) is included for Service Connect topology.
#   - IAM and Resource Explorer are global; no region constraint applies.
#####################################################################################

resource "aws_iam_policy" "devops_agent_boundary" {
  name        = "${var.role_name}-PermissionsBoundary"
  description = "Permissions boundary scoping DevOps Agent to ECS resources in ${var.aws_region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ── ECS: cluster, service, task ────────────────────────────────────────────
      {
        Sid    = "ECSRead"
        Effect = "Allow"
        Action = [
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "ecs:ListServices",
          "ecs:DescribeServices",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTaskDefinitions",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeCapacityProviders",
          "ecs:ListTagsForResource",
          "ecs:GetTaskProtection",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── Cloud Map (Service Connect and service discovery) ─────────────────────
      {
        Sid    = "ServiceDiscoveryRead"
        Effect = "Allow"
        Action = [
          "servicediscovery:ListNamespaces",
          "servicediscovery:GetNamespace",
          "servicediscovery:ListServices",
          "servicediscovery:GetService",
          "servicediscovery:ListInstances",
          "servicediscovery:GetInstance",
          "servicediscovery:GetOperation",
          "servicediscovery:ListOperations",
          "servicediscovery:ListTagsForResource",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── CloudWatch Logs: ARN-scoped to region ─────────────────────────────────
      # Covers ECS task logs (typically /ecs/<service-name>) and FireLens output.
      {
        Sid    = "CloudWatchLogsARNScoped"
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:DescribeLogStreams",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:DescribeSubscriptionFilters",
          "logs:DescribeMetricFilters",
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:*:log-group:*",
          "arn:aws:logs:${var.aws_region}:*:log-group:*:*",
        ]
      },
      {
        Sid    = "CloudWatchLogsAccountLevel"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeQueries",
          "logs:GetLogRecord",
          "logs:DescribeDestinations",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── CloudWatch metrics and alarms ─────────────────────────────────────────
      {
        Sid    = "CloudWatchMetrics"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricWidgetImage",
          "cloudwatch:ListDashboards",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },
      {
        Sid    = "CloudWatchAlarmsRead"
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:ListTagsForResource",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── ECR: ARN-scoped to region ─────────────────────────────────────────────
      {
        Sid    = "ECRARNScoped"
        Effect = "Allow"
        Action = [
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeImageScanFindings",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListTagsForResource",
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:*:repository/*"
      },
      {
        Sid    = "ECRAccountLevel"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRegistry",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── ALB: Describe ops are account-wide — regional scope only ──────────────
      {
        Sid    = "ALBRead"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeSSLPolicies",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── VPC / EC2 networking: Describe ops are account-wide — regional only ───
      {
        Sid    = "NetworkingRead"
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeRegions",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeTags",
          "ec2:DescribeImages",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── CloudTrail ────────────────────────────────────────────────────────────
      {
        Sid    = "CloudTrailRead"
        Effect = "Allow"
        Action = [
          "cloudtrail:LookupEvents",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus",
          "cloudtrail:GetEventSelectors",
          "cloudtrail:ListTrails",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── IAM: global service — no aws:RequestedRegion ─────────────────────────
      {
        Sid    = "IAMRead"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListRoles",
          "iam:ListInstanceProfiles",
          "iam:GetInstanceProfile",
          "iam:SimulatePrincipalPolicy",
        ]
        Resource = "*"
      },

      # ── Application Auto Scaling (ECS service scaling) ────────────────────────
      {
        Sid    = "AutoScalingRead"
        Effect = "Allow"
        Action = [
          "application-autoscaling:DescribeScalableTargets",
          "application-autoscaling:DescribeScalingActivities",
          "application-autoscaling:DescribeScalingPolicies",
          "application-autoscaling:DescribeScheduledActions",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── Resource Explorer — topology discovery (global aggregator) ────────────
      {
        Sid    = "ResourceExplorer"
        Effect = "Allow"
        Action = [
          "resource-explorer-2:Search",
          "resource-explorer-2:GetIndex",
          "resource-explorer-2:GetView",
          "resource-explorer-2:ListViews",
          "resource-explorer-2:ListIndexes",
          "resource-explorer-2:GetDefaultView",
          "resource-explorer-2:BatchGetView",
          "resource-explorer-2:ListIndexesForMembers",
          "resource-explorer-2:ListResources",
          "resource-explorer-2:ListStreamingAccessForServices",
          "resource-explorer-2:ListSupportedResourceTypes",
          "resource-explorer-2:ListTagsForResource",
        ]
        Resource = "*"
      },

      # ── STS ───────────────────────────────────────────────────────────────────
      {
        Sid      = "STSRead"
        Effect   = "Allow"
        Action   = ["sts:GetCallerIdentity"]
        Resource = "*"
      },

      # ── Resource Explorer SLR — must be in boundary as well as role policy ────
      {
        Sid    = "AllowResourceExplorerSLR"
        Effect = "Allow"
        Action = "iam:CreateServiceLinkedRole"
        Resource = "*"
        Condition = {
          StringEquals = { "iam:AWSServiceName" = "resource-explorer-2.amazonaws.com" }
        }
      },
    ]
  })

  tags = var.tags
}
