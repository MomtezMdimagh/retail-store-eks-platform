data "aws_iam_policy_document" "github_actions_ecr_push" {
  statement {
    sid       = "AllowAuthToken"
    actions   = ["ecr:GetAuthorizationToken"] # this action has no resource-level permissions
    resources = ["*"]
  }

  statement {
    sid = "AllowPushToRetailStoreRepos"
    actions = [
      "ecr:BatchCheckLayerAvailability", "ecr:PutImage", "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart", "ecr:CompleteLayerUpload", "ecr:BatchGetImage",
    ]
    resources = concat(
      [for r in aws_ecr_repository.images : r.arn],
      [for r in aws_ecr_repository.charts : r.arn],
    )
  }
}

resource "aws_iam_policy" "github_actions_ecr_push" {
  name   = "github-actions-ecr-push"
  policy = data.aws_iam_policy_document.github_actions_ecr_push.json
  tags = {
    Environment = var.environment_name
    Project     = "retail-store-eks-platform"
  }
}

module "github_oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.3.0"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["MomtezMdimagh/retail-store-sample-app:ref:refs/heads/main"]
  oidc_role_attach_policies = [aws_iam_policy.github_actions_ecr_push.arn]
}
