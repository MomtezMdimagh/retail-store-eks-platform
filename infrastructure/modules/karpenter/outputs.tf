output "node_role_name" {
  value       = aws_iam_role.karpenter_node.name
  description = "Node IAM role name - referenced by platform/karpenter/ec2nodeclass.yaml's spec.role field"
}

output "interruption_queue_name" {
  value       = aws_sqs_queue.karpenter_interruption.name
  description = "SQS queue name, for reference/debugging"
}

output "node_instance_families" {
  value = var.node_instance_families
}

output "node_cpu_limit" {
  value = var.node_cpu_limit
}

output "node_memory_limit" {
  value = var.node_memory_limit
}
