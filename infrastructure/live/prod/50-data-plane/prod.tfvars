environment_name          = "prod"
cluster_name              = "retail-store-eks-prod"
upstream_state_key_prefix = "prod/"
mysql_engine_version      = "8.4.11"
postgres_engine_version   = "18.6"
redis_engine_version      = "7.1"

# Real production data now - both true/longer than dev's false/7 days.
deletion_protection     = true
backup_retention_period = 30

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
