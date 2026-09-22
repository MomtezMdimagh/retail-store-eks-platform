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
  description = "EKS cluster name Karpenter provisions nodes into"
  type        = string
}

variable "karpenter_chart_version" {
  description = "Karpenter Helm chart version - check github.com/aws/karpenter-provider-aws releases before setting"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource this layer creates"
  type        = map(string)
  default     = {}
}
