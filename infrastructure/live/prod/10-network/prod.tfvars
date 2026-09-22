environment_name = "prod"
vpc_cidr         = "10.1.0.0/16" # not 10.0.0.0/16 (dev's) - avoids collision if these VPCs are ever peered
az_count         = 3
cluster_name     = "retail-store-eks-prod"

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
