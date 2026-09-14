module "github_oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.3.0"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["MomtezMdimagh/retail-store-sample-app:ref:refs/heads/main"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
}
