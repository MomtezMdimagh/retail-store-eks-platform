module "observability" {
  source = "../../../modules/observability"

  environment_name                 = var.environment_name
  cluster_name                     = var.cluster_name
  adot_addon_version               = var.adot_addon_version
  cert_manager_addon_version       = var.cert_manager_addon_version
  kube_state_metrics_addon_version = var.kube_state_metrics_addon_version
  node_exporter_addon_version      = var.node_exporter_addon_version
  log_retention_days               = var.log_retention_days
  tags                             = var.tags
}
