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

  # GitHub's newer repos (this one included) issue OIDC tokens with an *immutable* subject built
  # from numeric owner/repo IDs rather than names - so a name-based trust never matches and every
  # build fails with "Not authorized to perform sts:AssumeRoleWithWebIdentity". The ID form is also
  # the safer one: it can't be hijacked by renaming or deleting-and-recreating the repository.
  # Read yours with: gh api repos/<owner>/<repo>/actions/oidc/customization/sub
  # (IDs are public identifiers, not secrets.)
  repositories              = ["MomtezMdimagh@111145291/retail-store-sample-app@1364419632:ref:refs/heads/main"]
  oidc_role_attach_policies = [aws_iam_policy.github_actions_ecr_push.arn]
}
