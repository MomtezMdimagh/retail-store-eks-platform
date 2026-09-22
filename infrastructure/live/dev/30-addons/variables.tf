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
  description = "EKS cluster name these add-ons install into"
  type        = string
}

variable "lbc_chart_version" {
  description = "aws-load-balancer-controller Helm chart version"
  type        = string
}

variable "secrets_store_csi_chart_version" {
  description = "secrets-store-csi-driver Helm chart version"
  type        = string
}

variable "secrets_store_csi_aws_provider_chart_version" {
  description = "secrets-store-csi-driver-provider-aws Helm chart version"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource this layer creates"
  type        = map(string)
  default     = {}
}
