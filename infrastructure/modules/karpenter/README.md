# Module: karpenter

Karpenter's control-plane side: controller IAM role and Pod Identity association, the Helm release,
and the SQS queue + EventBridge rules that feed it spot-interruption notices. Node-shape policy
itself (EC2NodeClass, NodePools) lives in `platform/karpenter/`, since ArgoCD manages that, not
Terraform.

**Built in:** PR 6 — `feat/karpenter`

## Status

Not yet implemented.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
