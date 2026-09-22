variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name the cart service runs in"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = { Terraform = "true" }
}
