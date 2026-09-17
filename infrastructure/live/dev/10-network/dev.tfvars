environment_name = "dev"
vpc_cidr         = "10.0.0.0/16"
az_count         = 3
cluster_name     = "retail-store-eks-dev"

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
