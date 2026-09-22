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
  description = "EKS cluster name observability is installed into"
  type        = string
}

variable "adot_addon_version" {
  description = "adot addon version - check AWS's currently supported versions before setting"
  type        = string
}

variable "cert_manager_addon_version" {
  description = "cert-manager addon version - check AWS's currently supported versions before setting"
  type        = string
}

variable "kube_state_metrics_addon_version" {
  description = "kube-state-metrics addon version - check AWS's currently supported versions before setting"
  type        = string
}

variable "node_exporter_addon_version" {
  description = "prometheus-node-exporter addon version - check AWS's currently supported versions before setting"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource this layer creates"
  type        = map(string)
  default     = {}
}
