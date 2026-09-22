module "eks_addons" {
  source = "../../../modules/eks-addons"

  environment_name                             = var.environment_name
  cluster_name                                 = var.cluster_name
  lbc_chart_version                            = var.lbc_chart_version
  secrets_store_csi_chart_version              = var.secrets_store_csi_chart_version
  secrets_store_csi_aws_provider_chart_version = var.secrets_store_csi_aws_provider_chart_version
  tags                                         = var.tags
}
