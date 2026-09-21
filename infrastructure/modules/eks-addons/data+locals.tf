locals {
  pod_identity_trust_principal = "pods.eks.amazonaws.com"
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
