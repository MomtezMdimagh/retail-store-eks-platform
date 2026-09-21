environment_name        = "dev"
cluster_name            = "retail-store-eks-dev"
karpenter_chart_version = "1.14.1"

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
