output "secret_arn" {
  value       = aws_db_instance.catalog.master_user_secret[0].secret_arn
  description = "Secrets Manager ARN holding the catalog MySQL master credentials"
}

output "endpoint" {
  value = aws_db_instance.catalog.endpoint
}

output "security_group_id" {
  value = aws_security_group.catalog.id
}
