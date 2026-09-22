output "secret_arn" {
  value       = aws_secretsmanager_secret.checkout.arn
  description = "Secrets Manager ARN holding the checkout Redis endpoint (no auth token - see main.tf)"
}

output "endpoint" {
  value       = aws_elasticache_replication_group.checkout.primary_endpoint_address
  description = "Plain Redis endpoint - no credential attached, safe to put directly in a values file"
}

output "security_group_id" {
  value = aws_security_group.checkout.id
}
