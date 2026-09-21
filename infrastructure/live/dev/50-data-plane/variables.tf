variable "aws_region" {
  description = "AWS region this layer deploys into"
  type        = string
  default     = "us-east-1"
}

variable "environment_name" {
  description = "Deployment environment name (e.g., dev, prod)"
  type        = string
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

variable "tags" {
  description = "Tags applied to every resource this layer creates"
  type        = map(string)
  default     = {}
}
