environment_name          = "prod"
cluster_name              = "retail-store-eks-prod"
upstream_state_key_prefix = "prod/"
argocd_chart_version      = "10.9.2"
ecr_registry              = "652197205931.dkr.ecr.us-east-1.amazonaws.com"
app_repo_url              = "https://github.com/MomtezMdimagh/retail-store-sample-app.git"
platform_repo_url         = "https://github.com/MomtezMdimagh/retail-store-eks-platform.git"

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
