#####################################################################################
# EKS Permissions Boundary
#
# Scopes the DevOps Agent to EKS and supporting services in a single region.
# Effective permissions = AIDevOpsAgentAccessPolicy ∩ this boundary.
#
# Scoping strategy (production-validated):
#   - Regional condition (aws:RequestedRegion) applied throughout.
#   - Tag-based conditions are NOT used for EKS cluster resources: account-level
#     list operations (ListClusters, ListServices) are account-wide in IAM and
#     silently deny if tag conditions are added — regional scoping is the reliable
#     mechanism here.
#   - CloudWatch Logs and ECR are scoped by region-qualified ARN wildcard.
#   - IAM and Resource Explorer are global; no region constraint applies.
#
# EKS kubectl access note:
#   eks:AccessKubernetesApi is included here but kubectl read access (describe
#   pods, events, logs) also requires an EKS access entry on each cluster.
#   See the EKS access entry setup guide — this is not managed by this module.
#####################################################################################

resource "aws_iam_policy" "devops_agent_boundary" {
  name        = "${var.role_name}-PermissionsBoundary"
  description = "Permissions boundary scoping DevOps Agent to EKS resources in ${var.aws_region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ── EKS: account-level ────────────────────────────────────────────────────
      # ListClusters and DescribeAddonVersions are account-wide in IAM — tag
      # conditions are not supported; regional scope only.
      {
        Sid    = "EKSAccountLevel"
        Effect = "Allow"
        Action = [
          "eks:ListClusters",
          "eks:DescribeAddonVersions",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── EKS: cluster and child resources ─────────────────────────────────────
      # Covers clusters, node groups, Fargate profiles, addons, access entries,
      # Pod Identity, Insights, and kubectl API access.
      {
        Sid    = "EKSClusterLevel"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:ListFargateProfiles",
          "eks:DescribeFargateProfile",
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:DescribeAddonConfiguration",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:ListAccessEntries",
          "eks:DescribeAccessEntry",
          "eks:DescribeAssociatedAccessPolicy",
          "eks:ListAssociatedAccessPolicies",
          "eks:ListAccessPolicies",
          "eks:ListPodIdentityAssociations",
          "eks:DescribePodIdentityAssociation",
          "eks:DescribeInsight",
          "eks:ListInsights",
          "eks:DescribeCapability",
          "eks:DescribeClusterVersions",
          "eks:ListTagsForResource",
          "eks:AccessKubernetesApi",
        ]
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = var.aws_region }
        }
      },

      # ── CloudWatch Logs: ARN-scoped to region ─────────────────────────────────
      # Covers EKS control plane logs (/aws/eks/) and Container Insights
      # (/aws/containerinsights/). Wildcard log group names — no env prefix filter.
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

      # ── Application Auto Scaling (EKS HPA and Karpenter targets) ─────────────
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
