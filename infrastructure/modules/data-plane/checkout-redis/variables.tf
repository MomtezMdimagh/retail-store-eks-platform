variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name the checkout service runs in"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID this cache deploys into"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the ElastiCache subnet group"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group ID - Redis ingress is allowed from this"
  type        = string
}

variable "engine_version" {
  description = "ElastiCache Redis engine version - check AWS's currently supported versions before setting"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t4g.micro"
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = { Terraform = "true" }
}
