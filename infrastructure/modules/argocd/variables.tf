variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name ArgoCD is installed into"
  type        = string
}

variable "argocd_chart_version" {
  description = "argo-cd Helm chart version - check github.com/argoproj/argo-helm before setting"
  type        = string
}

variable "ecr_registry" {
  description = "ECR registry hostname (account-id.dkr.ecr.region.amazonaws.com) charts are pulled from"
  type        = string
}

variable "app_repo_url" {
  description = "Git URL of the app repository ArgoCD's AppProject allows as a source"
  type        = string
}

variable "platform_repo_url" {
  description = "Git URL of this platform repository - the second source ArgoCD's AppProject allows"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = { Terraform = "true" }
}
