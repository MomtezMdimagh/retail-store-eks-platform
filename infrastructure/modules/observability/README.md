# Module: observability

The AWS-managed side of the observability stack: cert-manager, the ADOT (AWS Distro for
OpenTelemetry) EKS add-on and its IAM role, node-exporter, kube-state-metrics, an Amazon Managed
Prometheus workspace, and an Amazon Managed Grafana workspace. Collector configuration itself
(what gets scraped, where traces go) lives in `platform/observability/`, since ArgoCD manages that.

**Built in:** PR 10 — `feat/observability`

## Status

Not yet implemented.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
