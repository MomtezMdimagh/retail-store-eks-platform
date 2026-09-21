environment_name                 = "dev"
cluster_name                     = "retail-store-eks-dev"
adot_addon_version               = "v0.156.0-eksbuild.1"
cert_manager_addon_version       = "v1.21.2-eksbuild.2"
kube_state_metrics_addon_version = "v2.20.0-eksbuild.6"
node_exporter_addon_version      = "v1.12.1-eksbuild.7"

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
