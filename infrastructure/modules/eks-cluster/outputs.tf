output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS cluster name"
}

output "cluster_arn" {
  value       = aws_eks_cluster.main.arn
  description = "EKS cluster ARN"
}

output "cluster_version" {
  value       = aws_eks_cluster.main.version
  description = "EKS Kubernetes version"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS API server endpoint"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Base64-encoded cluster CA certificate, needed to build a kubeconfig"
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description = "EKS-managed cluster security group ID - later layers (data plane) allow ingress from this"
}

output "node_role_arn" {
  value       = aws_iam_role.eks_node.arn
  description = "IAM role ARN worker nodes assume"
}

output "to_configure_kubectl" {
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${data.aws_region.current.region}"
  description = "Command to point your local kubectl at this cluster"
}
