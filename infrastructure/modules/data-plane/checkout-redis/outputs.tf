output "secret_arn" {
  value       = aws_secretsmanager_secret.checkout.arn
  description = "Secrets Manager ARN holding the checkout Redis auth token and endpoint"
}

output "security_group_id" {
  value = aws_security_group.checkout.id
}
