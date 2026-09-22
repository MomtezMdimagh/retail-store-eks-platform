module "argocd" {
  source = "../../../modules/argocd"

  environment_name     = var.environment_name
  cluster_name         = var.cluster_name
  argocd_chart_version = var.argocd_chart_version
  ecr_registry         = var.ecr_registry
  app_repo_url         = var.app_repo_url
  platform_repo_url    = var.platform_repo_url
  tags                 = var.tags
}
