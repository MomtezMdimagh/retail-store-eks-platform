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
  description = "EKS cluster name - must match the value used in the network layer's subnet tags"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the control plane"
  type        = string
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public EKS endpoint - wide open by default for dev convenience, tighten per environment"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to every resource this layer creates"
  type        = map(string)
  default     = {}
}
