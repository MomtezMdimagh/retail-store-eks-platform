output "secret_arn" {
  value       = aws_db_instance.orders.master_user_secret[0].secret_arn
  description = "Secrets Manager ARN holding the orders PostgreSQL master credentials"
}

output "endpoint" {
  value = aws_db_instance.orders.endpoint
}

output "queue_url" {
  value = aws_sqs_queue.orders.url
}

output "queue_arn" {
  value = aws_sqs_queue.orders.arn
}

output "security_group_id" {
  value = aws_security_group.orders.id
}
