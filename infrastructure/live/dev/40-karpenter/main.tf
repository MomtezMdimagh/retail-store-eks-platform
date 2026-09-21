module "karpenter" {
  source = "../../../modules/karpenter"

  environment_name        = var.environment_name
  cluster_name            = var.cluster_name
  cluster_endpoint        = data.terraform_remote_state.cluster.outputs.cluster_endpoint
  karpenter_chart_version = var.karpenter_chart_version
  tags                    = var.tags
}
