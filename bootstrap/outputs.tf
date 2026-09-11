output "tfstate_bucket_arn" {
  description = "ARN of the Terraform remote state S3 bucket"
  value       = aws_s3_bucket.tfstate_bucket.arn
}

output "tfstate_bucket_id" {
  description = "Bucket ID (same as name) for Terraform state"
  value       = aws_s3_bucket.tfstate_bucket.id
}

output "image_repository_urls" {
  description = "ECR repository URLs for container images"
  value       = { for service, repo in aws_ecr_repository.images : service => repo.repository_url }
}

output "chart_repository_urls" {
  description = "ECR repository URLs for Helm charts"
  value       = { for service, repo in aws_ecr_repository.charts : service => repo.repository_url }
}
