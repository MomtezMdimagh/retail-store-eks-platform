# Module: data-plane/orders-postgres

RDS Postgres for the orders service, an SQS queue for order-processing events, and the IAM role +
Pod Identity association that let the orders pod reach both without static credentials.

**Built in:** PR 7 — `feat/data-plane`

## Status

Implemented.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.66.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_db_instance.orders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.orders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_eks_pod_identity_association.orders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_policy.orders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.orders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.orders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.orders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.orders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_iam_policy_document.orders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pod_identity_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain automated backups | `number` | `7` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name the orders service runs in | `string` | n/a | yes |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | EKS cluster security group ID - PostgreSQL ingress is allowed from this | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to enable RDS deletion protection - true once this stops being a dev-only environment | `bool` | `false` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | RDS PostgreSQL engine version - check AWS's currently supported versions before setting | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Environment name used in resource names and tags | `string` | `"dev"` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | RDS instance class | `string` | `"db.t4g.micro"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs for the DB subnet group | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every resource this module creates | `map(string)` | <pre>{<br/>  "Terraform": "true"<br/>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID this database deploys into | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | n/a |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | n/a |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | n/a |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | Secrets Manager ARN holding the orders PostgreSQL master credentials |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
<!-- END_TF_DOCS -->
