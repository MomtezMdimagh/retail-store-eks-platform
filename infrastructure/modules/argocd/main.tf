# --- ArgoCD itself ---

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = local.argocd_namespace
  create_namespace = true
  wait             = true
  timeout          = 600
}

# --- App-of-apps bootstrap: the one legitimate exception to "platform/ is never applied directly" ---

resource "kubernetes_manifest" "app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-of-apps"
      namespace = local.argocd_namespace
    }
    spec = {
      project = "default" # the real AppProject lives in gitops/ and is picked up by this Application
      source = {
        repoURL        = var.platform_repo_url
        targetRevision = "main"
        path           = "gitops/environments/dev/applications"
        directory = {
          recurse = true
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = local.argocd_namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }

  depends_on = [helm_release.argocd]
}

# --- ECR OCI credential refresher for the repo-server ---
#
# ArgoCD's repository credentials for private Helm OCI registries are static; ECR authorization
# tokens expire every 12 hours. There is no native IAM-based passwordless path for this (confirmed
# against current ArgoCD/ECR documentation, not assumed) - a small CronJob refreshing a labeled
# Kubernetes Secret is the real, documented pattern, so that's what this is, built from two
# well-known public images rather than depending on a small, unmaintained third-party updater.

data "aws_iam_policy_document" "ecr_updater" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"] # this action has no resource-level permissions
    resources = ["*"]
  }
}

resource "aws_iam_role" "ecr_updater" {
  name               = "${var.cluster_name}-argocd-ecr-updater-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_policy" "ecr_updater" {
  name   = "${var.cluster_name}-argocd-ecr-updater-policy"
  policy = data.aws_iam_policy_document.ecr_updater.json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "ecr_updater" {
  role       = aws_iam_role.ecr_updater.name
  policy_arn = aws_iam_policy.ecr_updater.arn
}

resource "kubernetes_service_account_v1" "ecr_updater" {
  metadata {
    name      = "argocd-ecr-updater"
    namespace = local.argocd_namespace
  }

  depends_on = [helm_release.argocd]
}

resource "aws_eks_pod_identity_association" "ecr_updater" {
  cluster_name    = var.cluster_name
  namespace       = local.argocd_namespace
  service_account = kubernetes_service_account_v1.ecr_updater.metadata[0].name
  role_arn        = aws_iam_role.ecr_updater.arn
}

resource "kubernetes_role_v1" "ecr_updater" {
  metadata {
    name      = "argocd-ecr-updater"
    namespace = local.argocd_namespace
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create", "update", "patch"]
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_role_binding_v1" "ecr_updater" {
  metadata {
    name      = "argocd-ecr-updater"
    namespace = local.argocd_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.ecr_updater.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.ecr_updater.metadata[0].name
    namespace = local.argocd_namespace
  }
}

resource "kubernetes_cron_job_v1" "ecr_updater" {
  metadata {
    name      = "argocd-ecr-updater"
    namespace = local.argocd_namespace
  }

  spec {
    schedule                      = "0 */6 * * *" # every 6 hours - well inside the 12h ECR token lifetime
    successful_jobs_history_limit = 1
    failed_jobs_history_limit     = 3

    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            service_account_name = kubernetes_service_account_v1.ecr_updater.metadata[0].name
            restart_policy       = "OnFailure"

            volume {
              name = "token"
              empty_dir {}
            }

            # aws-cli:latest is a deliberate exception to this project's pin-everything discipline -
            # this is a small internal utility with no reproducibility/support-window concern the
            # way RDS/EKS/Helm chart versions have.
            init_container {
              name    = "fetch-token"
              image   = "public.ecr.aws/aws-cli/aws-cli:latest"
              command = ["sh", "-c", "aws ecr get-login-password --region ${data.aws_region.current.region} > /token/password"]

              volume_mount {
                name       = "token"
                mount_path = "/token"
              }
            }

            container {
              name  = "update-secret"
              image = "bitnami/kubectl:latest"
              command = ["sh", "-c", <<-EOT
                kubectl create secret generic argocd-ecr-creds \
                  --namespace ${local.argocd_namespace} \
                  --from-literal=type=helm \
                  --from-literal=url=${var.ecr_registry} \
                  --from-literal=enableOCI=true \
                  --from-literal=username=AWS \
                  --from-literal=password="$(cat /token/password)" \
                  --dry-run=client -o yaml | kubectl label -f - --local -o yaml \
                  argocd.argoproj.io/secret-type=repository | kubectl apply -f -
              EOT
              ]

              volume_mount {
                name       = "token"
                mount_path = "/token"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_role_binding_v1.ecr_updater]
}
