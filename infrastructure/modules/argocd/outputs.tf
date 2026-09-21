output "argocd_namespace" {
  value = local.argocd_namespace
}

output "ecr_updater_role_arn" {
  value = aws_iam_role.ecr_updater.arn
}
