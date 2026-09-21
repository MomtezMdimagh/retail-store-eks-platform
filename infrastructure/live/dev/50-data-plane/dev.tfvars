environment_name        = "dev"
cluster_name            = "retail-store-eks-dev"
mysql_engine_version    = "8.4.11"
postgres_engine_version = "18.6"
redis_engine_version    = "7.1"

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
