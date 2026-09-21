output "amp_workspace_id" {
  value = aws_prometheus_workspace.this.id
}

output "amp_remote_write_endpoint" {
  value       = "${aws_prometheus_workspace.this.prometheus_endpoint}api/v1/remote_write"
  description = "Full remote-write URL for the metrics collector config in platform/observability/"
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.observability.name
}

output "region" {
  value = data.aws_region.current.region
}

output "grafana_workspace_endpoint" {
  value       = var.enable_managed_grafana ? aws_grafana_workspace.this[0].endpoint : null
  description = "null until enable_managed_grafana is true and IAM Identity Center is enabled on this account"
}
