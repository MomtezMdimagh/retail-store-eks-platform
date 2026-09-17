variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

variable "subnet_newbits" {
  description = "Number of new bits to add to VPC CIDR to generate subnets (e.g., 8 means /24 from /16)"
  type        = number
  default     = 8
}

variable "az_count" {
  description = "Number of availability zones to use for subnets"
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "az_count must be between 2 and 4."
  }
}

variable "cluster_name" {
  description = "Name the EKS cluster will use - needed here to tag subnets for EKS/load-balancer-controller discovery before the cluster itself exists"
  type        = string
}
