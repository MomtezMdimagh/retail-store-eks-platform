module "eks_cluster" {
  source = "../../../modules/eks-cluster"

  environment_name   = var.environment_name
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  tags               = var.tags
}
