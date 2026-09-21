environment_name = "dev"
cluster_name     = "retail-store-eks-dev"

lbc_chart_version                            = "3.5.0"
secrets_store_csi_chart_version              = "1.6.1"
secrets_store_csi_aws_provider_chart_version = "3.1.4"

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
