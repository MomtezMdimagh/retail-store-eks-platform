variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name - must match the value used to tag VPC subnets in modules/vpc"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the control plane (e.g. \"1.31\") - check AWS's currently supported versions before setting; no default on purpose since EKS deprecates versions on a rolling schedule"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the control plane ENIs and worker nodes"
  type        = list(string)
}

variable "cluster_endpoint_private_access" {
  description = "Allow the EKS API endpoint to be reached from inside the VPC"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Allow the EKS API endpoint to be reached from the internet (needed for kubectl from your own machine in dev)"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public EKS endpoint. Defaults wide open for dev convenience - tighten this for a real production environment"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_service_ipv4_cidr" {
  description = "CIDR for Kubernetes Services - must not overlap the VPC CIDR"
  type        = string
  default     = "172.20.0.0/16"
}

variable "cluster_log_retention_days" {
  description = "Retention for the EKS control plane CloudWatch log group"
  type        = number
  default     = 7
}

variable "node_instance_types" {
  description = "EC2 instance types for the baseline managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT for the baseline node group"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_desired_size" {
  description = "Desired worker node count for the baseline node group"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum worker node count"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum worker node count"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Root volume size (GiB) for each worker node"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}
