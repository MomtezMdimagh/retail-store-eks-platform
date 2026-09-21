
# Module: eks-addons

Installs the add-ons that make the EKS cluster usable for real workloads: the Pod Identity agent
(the mechanism every other component here depends on), the AWS Load Balancer Controller (provisions
ALBs/NLBs from Kubernetes Ingress/Service objects, using the subnet discovery tags from the vpc
module), the EBS CSI driver (persistent volumes), the Secrets Store CSI driver with its AWS provider
(mounting Secrets Manager values into pods), ExternalDNS (automatic Route53 record management), and
metrics-server (the metrics API the Horizontal Pod Autoscaler later depends on). Every component
that needs AWS permissions uses EKS Pod Identity exclusively - no IRSA, no OIDC provider.

**Built in:** PR 5 — `feat/eks_add_ons`

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

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_eks_addon.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.metrics_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.pod_identity_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_pod_identity_association.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_eks_pod_identity_association.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_eks_pod_identity_association.lbc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_policy.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lbc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lbc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lbc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.lbc](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.secrets_store_csi_aws_provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.secrets_store_csi_driver](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_iam_policy_document.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pod_identity_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name these add-ons install into | `string` | n/a | yes |
| <a name="input_ebs_csi_addon_version"></a> [ebs\_csi\_addon\_version](#input\_ebs\_csi\_addon\_version) | aws-ebs-csi-driver addon version - leave null to use the AWS default | `string` | `null` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Environment name used in resource names and tags | `string` | `"dev"` | no |
| <a name="input_external_dns_addon_version"></a> [external\_dns\_addon\_version](#input\_external\_dns\_addon\_version) | external-dns addon version - leave null to use the AWS default | `string` | `null` | no |
| <a name="input_lbc_chart_version"></a> [lbc\_chart\_version](#input\_lbc\_chart\_version) | aws-load-balancer-controller Helm chart version - check the eks-charts repo before setting | `string` | n/a | yes |
| <a name="input_metrics_server_addon_version"></a> [metrics\_server\_addon\_version](#input\_metrics\_server\_addon\_version) | metrics-server addon version - leave null to use the AWS default | `string` | `null` | no |
| <a name="input_pod_identity_agent_addon_version"></a> [pod\_identity\_agent\_addon\_version](#input\_pod\_identity\_agent\_addon\_version) | eks-pod-identity-agent addon version - leave null to use the AWS default for this cluster version | `string` | `null` | no |
| <a name="input_secrets_store_csi_aws_provider_chart_version"></a> [secrets\_store\_csi\_aws\_provider\_chart\_version](#input\_secrets\_store\_csi\_aws\_provider\_chart\_version) | secrets-store-csi-driver-provider-aws Helm chart version | `string` | n/a | yes |
| <a name="input_secrets_store_csi_chart_version"></a> [secrets\_store\_csi\_chart\_version](#input\_secrets\_store\_csi\_chart\_version) | secrets-store-csi-driver Helm chart version | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every resource this module creates | `map(string)` | <pre>{<br/>  "Terraform": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_lbc_role_arn"></a> [lbc\_role\_arn](#output\_lbc\_role\_arn) | IAM role the Load Balancer Controller assumes, for reference/debugging |
<!-- END_TF_DOCS -->
