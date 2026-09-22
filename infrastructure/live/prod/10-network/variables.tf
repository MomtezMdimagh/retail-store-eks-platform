variable "aws_region" {
  description = "AWS region this layer deploys into"
  type        = string
  default     = "us-east-1"
}

variable "environment_name" {
  description = "Deployment environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for this environment's VPC"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across"
  type        = number
  default     = 3
}

variable "cluster_name" {
  description = "Name the EKS cluster will use in this environment - must match PR 4's cluster exactly"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource this layer creates"
  type        = map(string)
  default     = {}
}
