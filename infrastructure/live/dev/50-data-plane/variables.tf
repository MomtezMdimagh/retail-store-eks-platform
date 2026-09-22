variable "aws_region" {
  description = "AWS region this layer deploys into"
  type        = string
  default     = "us-east-1"
}

variable "environment_name" {
  description = "Deployment environment name (e.g., dev, prod)"
  type        = string
}

variable "upstream_state_key_prefix" {
  description = "Prefix for this environment's own upstream layer state keys in the shared state bucket - empty for dev, \"prod/\" for prod, since only prod's keys carry an environment prefix (a naming artifact from when the bucket was first created dev-only)"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "EKS cluster name workload pods run in"
  type        = string
}

variable "mysql_engine_version" {
  description = "RDS MySQL engine version - check AWS's currently supported versions before setting"
  type        = string
}

variable "postgres_engine_version" {
  description = "RDS PostgreSQL engine version - check AWS's currently supported versions before setting"
  type        = string
}

variable "redis_engine_version" {
  description = "ElastiCache Redis engine version - check AWS's currently supported versions before setting"
  type        = string
}

variable "deletion_protection" {
  description = "Whether to enable RDS deletion protection on catalog-mysql and orders-postgres - true once this stops being a dev-only environment"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated RDS backups for catalog-mysql and orders-postgres"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to every resource this layer creates"
  type        = map(string)
  default     = {}
}
