locals {
  pod_identity_trust_principal = "pods.eks.amazonaws.com"
  interruption_queue_name      = "${var.cluster_name}-karpenter-interruption"

  node_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]

  interruption_rules = {
    health_event      = { source = "aws.health", detail_type = "AWS Health Event" }
    spot_interruption = { source = "aws.ec2", detail_type = "EC2 Spot Instance Interruption Warning" }
    rebalance         = { source = "aws.ec2", detail_type = "EC2 Instance Rebalance Recommendation" }
    state_change      = { source = "aws.ec2", detail_type = "EC2 Instance State-change Notification" }
  }
}

data "aws_iam_policy_document" "pod_identity_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = [local.pod_identity_trust_principal]
    }
  }
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
