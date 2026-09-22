variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name the orders service runs in"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID this database deploys into"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group ID - PostgreSQL ingress is allowed from this"
  type        = string
}

variable "engine_version" {
  description = "RDS PostgreSQL engine version - check AWS's currently supported versions before setting"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = { Terraform = "true" }
}
