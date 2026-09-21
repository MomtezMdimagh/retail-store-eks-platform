variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name Karpenter provisions nodes into"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS API server endpoint - passed to the Karpenter controller directly"
  type        = string
}

variable "karpenter_chart_version" {
  description = "Karpenter Helm chart version - check github.com/aws/karpenter-provider-aws releases before setting"
  type        = string
}

variable "node_instance_families" {
  description = "EC2 instance families Karpenter may provision"
  type        = list(string)
  default     = ["t3", "t3a"]
}

variable "node_cpu_limit" {
  description = "Total vCPU limit across all Karpenter-provisioned nodes, per NodePool"
  type        = string
  default     = "50"
}

variable "node_memory_limit" {
  description = "Total memory limit (Gi) across all Karpenter-provisioned nodes, per NodePool"
  type        = string
  default     = "100Gi"
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = { Terraform = "true" }
}
