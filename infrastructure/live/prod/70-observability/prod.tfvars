environment_name                 = "prod"
cluster_name                     = "retail-store-eks-prod"
adot_addon_version               = "v0.156.0-eksbuild.1"
cert_manager_addon_version       = "v1.21.2-eksbuild.2"
kube_state_metrics_addon_version = "v2.20.0-eksbuild.6"
node_exporter_addon_version      = "v1.12.1-eksbuild.7"

# Longer than dev's 14 days - real production log history is worth keeping around.
log_retention_days = 90

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
