output "argocd_namespace" {
  value = module.argocd.argocd_namespace
}

output "ecr_updater_role_arn" {
  value = module.argocd.ecr_updater_role_arn
}
