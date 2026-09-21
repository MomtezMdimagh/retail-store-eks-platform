output "node_role_name" {
  value = module.karpenter.node_role_name
}

output "node_instance_families" {
  value = module.karpenter.node_instance_families
}

output "node_cpu_limit" {
  value = module.karpenter.node_cpu_limit
}

output "node_memory_limit" {
  value = module.karpenter.node_memory_limit
}
