# --- ADOT operator (depends on cert-manager, per AWS's documented addon dependency) ---

resource "aws_eks_addon" "cert_manager" {
  cluster_name  = var.cluster_name
  addon_name    = "cert-manager"
  addon_version = var.cert_manager_addon_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_eks_addon" "adot" {
  cluster_name  = var.cluster_name
  addon_name    = "adot"
  addon_version = var.adot_addon_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_addon.cert_manager]
  tags       = merge(var.tags, { Environment = var.environment_name })
}

# --- The two metrics sources ADOT's Prometheus receiver actually scrapes ---

resource "aws_eks_addon" "kube_state_metrics" {
  cluster_name  = var.cluster_name
  addon_name    = "kube-state-metrics"
  addon_version = var.kube_state_metrics_addon_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_eks_addon" "node_exporter" {
  cluster_name  = var.cluster_name
  addon_name    = "prometheus-node-exporter"
  addon_version = var.node_exporter_addon_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(var.tags, { Environment = var.environment_name })
}

# --- Explicitly-retained log group for application traces/logs, not an auto-created unbounded one ---

resource "aws_cloudwatch_log_group" "observability" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { Environment = var.environment_name })
}

# --- Amazon Managed Prometheus ---

resource "aws_prometheus_workspace" "this" {
  alias = "${var.cluster_name}-amp"
  tags  = merge(var.tags, { Environment = var.environment_name })
}

# --- Three separate, narrowly-scoped IAM roles - one per collector, not one shared role ---

data "aws_iam_policy_document" "traces" {
  statement {
    actions   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
    resources = ["*"] # X-Ray write actions have no resource-level permissions
  }
}

resource "aws_iam_role" "traces" {
  name               = "${var.cluster_name}-adot-traces-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_policy" "traces" {
  name   = "${var.cluster_name}-adot-traces-policy"
  policy = data.aws_iam_policy_document.traces.json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "traces" {
  role       = aws_iam_role.traces.name
  policy_arn = aws_iam_policy.traces.arn
}

resource "aws_eks_pod_identity_association" "traces" {
  cluster_name    = var.cluster_name
  namespace       = "observability"
  service_account = "adot-traces-collector"
  role_arn        = aws_iam_role.traces.arn
}

data "aws_iam_policy_document" "logs" {
  statement {
    actions = ["logs:PutLogEvents", "logs:CreateLogStream", "logs:DescribeLogStreams"]
    resources = [
      aws_cloudwatch_log_group.observability.arn,
      "${aws_cloudwatch_log_group.observability.arn}:*",
    ]
  }
}

resource "aws_iam_role" "logs" {
  name               = "${var.cluster_name}-adot-logs-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_policy" "logs" {
  name   = "${var.cluster_name}-adot-logs-policy"
  policy = data.aws_iam_policy_document.logs.json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.logs.name
  policy_arn = aws_iam_policy.logs.arn
}

resource "aws_eks_pod_identity_association" "logs" {
  cluster_name    = var.cluster_name
  namespace       = "observability"
  service_account = "adot-logs-collector"
  role_arn        = aws_iam_role.logs.arn
}

data "aws_iam_policy_document" "metrics" {
  statement {
    actions   = ["aps:RemoteWrite"]
    resources = [aws_prometheus_workspace.this.arn]
  }
}

resource "aws_iam_role" "metrics" {
  name               = "${var.cluster_name}-adot-metrics-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_policy" "metrics" {
  name   = "${var.cluster_name}-adot-metrics-policy"
  policy = data.aws_iam_policy_document.metrics.json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "metrics" {
  role       = aws_iam_role.metrics.name
  policy_arn = aws_iam_policy.metrics.arn
}

resource "aws_eks_pod_identity_association" "metrics" {
  cluster_name    = var.cluster_name
  namespace       = "observability"
  service_account = "adot-metrics-collector"
  role_arn        = aws_iam_role.metrics.arn
}

# --- Amazon Managed Grafana (opt-in - requires IAM Identity Center already enabled) ---

data "aws_iam_policy_document" "amg_assume" {
  count = var.enable_managed_grafana ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["grafana.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "amg_read" {
  count = var.enable_managed_grafana ? 1 : 0

  statement {
    actions   = ["aps:ListWorkspaces", "aps:DescribeWorkspace", "aps:QueryMetrics", "aps:GetLabels", "aps:GetSeries", "aps:GetMetricMetadata"]
    resources = [aws_prometheus_workspace.this.arn]
  }
}

resource "aws_iam_role" "amg" {
  count              = var.enable_managed_grafana ? 1 : 0
  name               = "${var.cluster_name}-amg-role"
  assume_role_policy = data.aws_iam_policy_document.amg_assume[0].json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_policy" "amg_read" {
  count  = var.enable_managed_grafana ? 1 : 0
  name   = "${var.cluster_name}-amg-amp-read"
  policy = data.aws_iam_policy_document.amg_read[0].json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "amg_read" {
  count      = var.enable_managed_grafana ? 1 : 0
  role       = aws_iam_role.amg[0].name
  policy_arn = aws_iam_policy.amg_read[0].arn
}

resource "aws_grafana_workspace" "this" {
  count                    = var.enable_managed_grafana ? 1 : 0
  name                     = "${var.cluster_name}-amg"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "CUSTOMER_MANAGED"
  role_arn                 = aws_iam_role.amg[0].arn
  data_sources             = ["PROMETHEUS", "CLOUDWATCH"]
  tags                     = merge(var.tags, { Environment = var.environment_name })
}
