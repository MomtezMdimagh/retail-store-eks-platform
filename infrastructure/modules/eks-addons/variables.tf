variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name these add-ons install into"
  type        = string
}

variable "lbc_chart_version" {
  description = "aws-load-balancer-controller Helm chart version - check the eks-charts repo before setting"
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

variable "pod_identity_agent_addon_version" {
  description = "eks-pod-identity-agent addon version - leave null to use the AWS default for this cluster version"
  type        = string
  default     = null
}

variable "ebs_csi_addon_version" {
  description = "aws-ebs-csi-driver addon version - leave null to use the AWS default"
  type        = string
  default     = null
}

variable "external_dns_addon_version" {
  description = "external-dns addon version - leave null to use the AWS default"
  type        = string
  default     = null
}

variable "metrics_server_addon_version" {
  description = "metrics-server addon version - leave null to use the AWS default"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = { Terraform = "true" }
}
