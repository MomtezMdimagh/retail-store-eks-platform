module "vpc" {
  source           = "../../../modules/vpc"
  environment_name = var.environment_name
  vpc_cidr         = var.vpc_cidr
  tags             = var.tags
  cluster_name     = var.cluster_name
  az_count         = var.az_count

}
