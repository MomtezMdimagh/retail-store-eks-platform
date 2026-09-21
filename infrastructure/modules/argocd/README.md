# Module: argocd

Installs ArgoCD via Helm and creates the one bootstrap `Application` (the app-of-apps root) that
lets everything else - the AppProject, per-service Applications, and platform manifests - be
GitOps-managed from `gitops/` and `platform/` instead of ever needing a manual `kubectl apply`. Also
runs a small CronJob that refreshes ArgoCD's ECR repository credentials every 6 hours, since ECR
authorization tokens expire every 12 hours and there is no native IAM-based passwordless path for
Helm OCI pulls from a private registry.

**Built in:** PR 8 — `feat/argocd`

## Status

Implemented.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.30 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.66.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_eks_pod_identity_association.ecr_updater](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_policy.ecr_updater](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecr_updater](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecr_updater](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cron_job_v1.ecr_updater](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cron_job_v1) | resource |
| [kubernetes_manifest.app_of_apps](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_role_binding_v1.ecr_updater](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1) | resource |
| [kubernetes_role_v1.ecr_updater](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_v1) | resource |
| [kubernetes_service_account_v1.ecr_updater](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [aws_iam_policy_document.ecr_updater](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pod_identity_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_repo_url"></a> [app\_repo\_url](#input\_app\_repo\_url) | Git URL of the app repository ArgoCD's AppProject allows as a source | `string` | n/a | yes |
| <a name="input_argocd_chart_version"></a> [argocd\_chart\_version](#input\_argocd\_chart\_version) | argo-cd Helm chart version - check github.com/argoproj/argo-helm before setting | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name ArgoCD is installed into | `string` | n/a | yes |
| <a name="input_ecr_registry"></a> [ecr\_registry](#input\_ecr\_registry) | ECR registry hostname (account-id.dkr.ecr.region.amazonaws.com) charts are pulled from | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Environment name used in resource names and tags | `string` | `"dev"` | no |
| <a name="input_platform_repo_url"></a> [platform\_repo\_url](#input\_platform\_repo\_url) | Git URL of this platform repository - the second source ArgoCD's AppProject allows | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every resource this module creates | `map(string)` | <pre>{<br/>  "Terraform": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_argocd_namespace"></a> [argocd\_namespace](#output\_argocd\_namespace) | n/a |
| <a name="output_ecr_updater_role_arn"></a> [ecr\_updater\_role\_arn](#output\_ecr\_updater\_role\_arn) | n/a |
<!-- END_TF_DOCS -->
