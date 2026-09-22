output "cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks_cluster.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  value = module.eks_cluster.cluster_security_group_id
}

output "node_role_arn" {
  value = module.eks_cluster.node_role_arn
}

output "to_configure_kubectl" {
  value = module.eks_cluster.to_configure_kubectl
}
