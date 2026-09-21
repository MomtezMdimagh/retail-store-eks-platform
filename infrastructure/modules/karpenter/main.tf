# --- Controller IAM role + policy ---

resource "aws_iam_role" "karpenter_controller" {
  name               = "${var.cluster_name}-karpenter-controller-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

data "aws_iam_policy_document" "karpenter_controller" {
  statement {
    sid       = "AllowScopedEC2InstanceActions"
    actions   = ["ec2:RunInstances", "ec2:CreateFleet", "ec2:CreateLaunchTemplate"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.current.region]
    }
  }

  statement {
    sid       = "AllowScopedResourceCreationTagging"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:*/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.current.region]
    }
    condition {
      test     = "StringLike"
      variable = "ec2:CreateAction"
      values   = ["RunInstances", "CreateFleet", "CreateLaunchTemplate"]
    }
  }

  statement {
    sid       = "AllowScopedDeletion"
    actions   = ["ec2:TerminateInstances", "ec2:DeleteLaunchTemplate"]
    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:*/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }
  }

  statement {
    sid = "AllowRegionalReadActions"
    actions = [
      "ec2:DescribeInstances", "ec2:DescribeImages", "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings", "ec2:DescribeAvailabilityZones",
      "ec2:DescribeLaunchTemplates", "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.current.region]
    }
  }

  statement {
    sid       = "AllowSSMReadActions"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*::parameter/aws/service/*"]
  }

  statement {
    sid       = "AllowPricingReadActions"
    actions   = ["pricing:GetProducts"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowInterruptionQueueActions"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueUrl", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
    resources = [aws_sqs_queue.karpenter_interruption.arn]
  }

  statement {
    sid       = "AllowPassingInstanceRole"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.karpenter_node.arn]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }

  statement {
    sid = "AllowScopedInstanceProfileActions"
    actions = [
      "iam:CreateInstanceProfile", "iam:TagInstanceProfile", "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }
  }

  statement {
    sid       = "AllowInstanceProfileListing"
    actions   = ["iam:ListInstanceProfiles"]
    resources = ["*"]
  }

  statement {
    sid       = "AllowDescribingCluster"
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:aws:eks:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"]
  }
}

resource "aws_iam_policy" "karpenter_controller" {
  name   = "${var.cluster_name}-karpenter-controller-policy"
  policy = data.aws_iam_policy_document.karpenter_controller.json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter_controller.arn
}

# --- Node IAM role (separate from the PR 4 managed-node-group role) ---

resource "aws_iam_role" "karpenter_node" {
  name               = "${var.cluster_name}-karpenter-node-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "karpenter_node" {
  for_each   = toset(local.node_policy_arns)
  role       = aws_iam_role.karpenter_node.name
  policy_arn = each.value
}

resource "aws_eks_access_entry" "karpenter_node" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.karpenter_node.arn
  type          = "EC2_LINUX"
}

# --- SQS interruption queue ---

resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = local.interruption_queue_name
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
  tags                      = merge(var.tags, { Environment = var.environment_name })
}

data "aws_iam_policy_document" "karpenter_interruption_queue" {
  statement {
    sid     = "AllowEventBridgeToSendMessages"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [aws_sqs_queue.karpenter_interruption.arn]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/*"]
    }
  }

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["sqs:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [aws_sqs_queue.karpenter_interruption.arn]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  queue_url = aws_sqs_queue.karpenter_interruption.id
  policy    = data.aws_iam_policy_document.karpenter_interruption_queue.json
}

# --- EventBridge rules feeding the interruption queue ---

resource "aws_cloudwatch_event_rule" "karpenter_interruption" {
  for_each      = local.interruption_rules
  name          = "${var.cluster_name}-karpenter-${each.key}"
  event_pattern = jsonencode({ source = [each.value.source], "detail-type" = [each.value.detail_type] })
  tags          = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_cloudwatch_event_target" "karpenter_interruption" {
  for_each = local.interruption_rules
  rule     = aws_cloudwatch_event_rule.karpenter_interruption[each.key].name
  arn      = aws_sqs_queue.karpenter_interruption.arn
}

# --- Karpenter controller Helm release ---

resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = var.karpenter_chart_version
  namespace        = "kube-system"
  create_namespace = false
  wait             = true
  timeout          = 600

  set = [
    { name = "settings.clusterName", value = var.cluster_name },
    { name = "settings.clusterEndpoint", value = var.cluster_endpoint },
    { name = "settings.interruptionQueue", value = aws_sqs_queue.karpenter_interruption.name },
    { name = "serviceAccount.name", value = "karpenter" },
    { name = "serviceAccount.create", value = "true" },
  ]

  depends_on = [
    aws_eks_pod_identity_association.karpenter,
    aws_eks_access_entry.karpenter_node,
    aws_sqs_queue_policy.karpenter_interruption,
  ]
}
