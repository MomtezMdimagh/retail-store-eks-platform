# Module: karpenter

Karpenter's control-plane side: controller IAM role and Pod Identity association, the Helm release,
and the SQS queue + EventBridge rules that feed it spot-interruption notices. Node-shape policy
itself (EC2NodeClass, NodePools) lives in `platform/karpenter/`, since ArgoCD manages that, not
Terraform.

**Built in:** PR 6 — `feat/karpenter`

## Status

Implemented.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |

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
| [aws_cloudwatch_event_rule.karpenter_interruption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.karpenter_interruption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_eks_access_entry.karpenter_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_pod_identity_association.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_policy.karpenter_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.karpenter_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.karpenter_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.karpenter_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.karpenter_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sqs_queue.karpenter_interruption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.karpenter_interruption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ec2_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.karpenter_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.karpenter_interruption_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pod_identity_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | EKS API server endpoint - passed to the Karpenter controller directly | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name Karpenter provisions nodes into | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Environment name used in resource names and tags | `string` | `"dev"` | no |
| <a name="input_karpenter_chart_version"></a> [karpenter\_chart\_version](#input\_karpenter\_chart\_version) | Karpenter Helm chart version - check github.com/aws/karpenter-provider-aws releases before setting | `string` | n/a | yes |
| <a name="input_node_cpu_limit"></a> [node\_cpu\_limit](#input\_node\_cpu\_limit) | Total vCPU limit across all Karpenter-provisioned nodes, per NodePool | `string` | `"50"` | no |
| <a name="input_node_instance_families"></a> [node\_instance\_families](#input\_node\_instance\_families) | EC2 instance families Karpenter may provision | `list(string)` | <pre>[<br/>  "t3",<br/>  "t3a"<br/>]</pre> | no |
| <a name="input_node_memory_limit"></a> [node\_memory\_limit](#input\_node\_memory\_limit) | Total memory limit (Gi) across all Karpenter-provisioned nodes, per NodePool | `string` | `"100Gi"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every resource this module creates | `map(string)` | <pre>{<br/>  "Terraform": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_interruption_queue_name"></a> [interruption\_queue\_name](#output\_interruption\_queue\_name) | SQS queue name, for reference/debugging |
| <a name="output_node_cpu_limit"></a> [node\_cpu\_limit](#output\_node\_cpu\_limit) | n/a |
| <a name="output_node_instance_families"></a> [node\_instance\_families](#output\_node\_instance\_families) | n/a |
| <a name="output_node_memory_limit"></a> [node\_memory\_limit](#output\_node\_memory\_limit) | n/a |
| <a name="output_node_role_name"></a> [node\_role\_name](#output\_node\_role\_name) | Node IAM role name - referenced by platform/karpenter/ec2nodeclass.yaml's spec.role field |
<!-- END_TF_DOCS -->
