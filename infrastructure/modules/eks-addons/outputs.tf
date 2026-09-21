output "lbc_role_arn" {
  value       = aws_iam_role.lbc.arn
  description = "IAM role the Load Balancer Controller assumes, for reference/debugging"
}
