environment_name          = "prod"
cluster_name              = "retail-store-eks-prod"
upstream_state_key_prefix = "prod/"
karpenter_chart_version   = "1.14.1"

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
