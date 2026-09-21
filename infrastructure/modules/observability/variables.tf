variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
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

variable "log_retention_days" {
  description = "Retention for the application traces/logs CloudWatch log group"
  type        = number
  default     = 14
}

variable "enable_managed_grafana" {
  description = "Create the Amazon Managed Grafana workspace. Requires IAM Identity Center already enabled on this account (a one-time, account-wide, manual setting) - leave false until that's done, since AMG creation will otherwise fail at apply time"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = { Terraform = "true" }
}
