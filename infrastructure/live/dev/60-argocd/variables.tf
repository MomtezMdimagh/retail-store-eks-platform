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
  description = "EKS cluster name ArgoCD is installed into"
  type        = string
}

variable "argocd_chart_version" {
  description = "argo-cd Helm chart version - check github.com/argoproj/argo-helm before setting"
  type        = string
}

variable "ecr_registry" {
  description = "ECR registry hostname charts are pulled from"
  type        = string
}

variable "app_repo_url" {
  description = "Git URL of the app repository ArgoCD's AppProject allows as a source"
  type        = string
}

variable "platform_repo_url" {
  description = "Git URL of this platform repository"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource this layer creates"
  type        = map(string)
  default     = {}
}
