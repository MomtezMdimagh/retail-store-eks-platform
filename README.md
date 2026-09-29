# retail-store-eks-platform

A production-shaped platform for a five-service retail application on **Amazon EKS**, built entirely as
code: layered **Terraform**, **Karpenter** node autoscaling, **Argo CD** GitOps, a fully AWS-managed data
plane, and OpenTelemetry-based observability.

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![Amazon EKS](https://img.shields.io/badge/Amazon%20EKS-FF9900?logo=amazoneks&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![Karpenter](https://img.shields.io/badge/Karpenter-FF9900?logo=amazonaws&logoColor=white)
![Argo CD](https://img.shields.io/badge/Argo%20CD-EF7B4D?logo=argo&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)
![OpenTelemetry](https://img.shields.io/badge/OpenTelemetry-425CC7?logo=opentelemetry&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

**Status:** the `dev` environment is **deployed and tested end to end**: browse the catalog, add to
cart, check out, order stored in PostgreSQL. `prod` is fully codified and validated against real
remote state, but deliberately not applied (cost).

The application is AWS's open-source
[retail-store-sample-app](https://github.com/aws-containers/retail-store-sample-app). This repo holds
none of its source; the [fork](https://github.com/MomtezMdimagh/retail-store-sample-app) adds the CI
that builds its images into ECR.

## Architecture

![Architecture diagram](docs/diagrams/generated/main-architecture.png)

`dev` and `prod` are structurally identical: same Terraform modules, same GitOps manifests, differing
only in their variables (VPC CIDR, retention windows, deletion protection) and their own isolated state,
cluster, and Argo CD instance.

## Tech stack

| Area | Tools |
|---|---|
| Infrastructure as code | Terraform (7 layered stacks), S3 remote state with native locking |
| Networking | VPC across 3 AZs, public/private subnets, single NAT gateway, AWS Load Balancer Controller, ExternalDNS |
| Compute | Amazon EKS 1.36, Karpenter (on-demand + spot, interruption handling via EventBridge + SQS) |
| Delivery | GitHub Actions (OIDC, no stored AWS keys) → Amazon ECR (images + OCI Helm charts) → Argo CD app-of-apps |
| Security | EKS Pod Identity for every workload, Secrets Store CSI Driver + AWS Secrets Manager, KMS-encrypted secrets |
| Data | RDS MySQL (catalog), RDS PostgreSQL (orders), DynamoDB (cart), ElastiCache Redis (checkout) |
| Observability | AWS Distro for OpenTelemetry → Amazon Managed Prometheus, CloudWatch Logs, X-Ray |
| Resilience | HPA, PodDisruptionBudgets, and zone-spread for every service |

## Key design decisions

- **Pod Identity everywhere, no IRSA.** Each workload that talks to AWS gets its own least-privilege IAM
  role through an EKS Pod Identity association.
- **Layered Terraform, one state per layer.** `infrastructure/modules/` holds environment-agnostic
  logic; `infrastructure/live/<env>/<NN-layer>/` roots are thin, and each layer reads the ones below it
  through `terraform_remote_state`, never through copied values.
- **GitOps split by what's truly shared.** `platform/` holds manifests every environment syncs
  identically; anything environment-specific (an `EC2NodeClass`, a metrics endpoint) lives under
  `gitops/environments/<env>/`.
- **Secrets never touch Git.** Database passwords are generated and stored by AWS and synced into pods
  by the Secrets Store CSI Driver.
- **Prod moves by reviewed PR, not by pipeline.** A new image reaches `prod` only through a pull request
  that copies a tag already proven in `dev`.
- **One NAT gateway, on purpose.** A fixed, known cost instead of per-AZ redundancy this project doesn't
  need.

## Getting started

The full apply sequence, from an empty account to a working checkout, is in
[`docs/runbooks/deploy.md`](docs/runbooks/deploy.md). In short:

1. `bootstrap/`: state bucket, ECR repositories, GitHub OIDC role (once per account).
2. `infrastructure/live/dev/` layers, in order: `10-network` → `70-observability`.
3. Argo CD takes over from there and syncs everything under `gitops/environments/dev/`.

## Repository layout

| Path | Purpose |
|---|---|
| [`bootstrap/`](bootstrap/) | Run once: S3 state backend, GitHub OIDC deploy role, ECR repositories |
| [`infrastructure/modules/`](infrastructure/modules/) | Reusable Terraform modules: [vpc](infrastructure/modules/vpc/), [eks-cluster](infrastructure/modules/eks-cluster/), [eks-addons](infrastructure/modules/eks-addons/), [karpenter](infrastructure/modules/karpenter/), [data-plane](infrastructure/modules/data-plane/), [argocd](infrastructure/modules/argocd/), [observability](infrastructure/modules/observability/) |
| [`infrastructure/live/`](infrastructure/live/) | Thin per-environment, per-layer roots for [`dev`](infrastructure/live/dev/) and [`prod`](infrastructure/live/prod/) |
| [`platform/`](platform/) | Cluster manifests shared by every environment: [Karpenter](platform/karpenter/) NodePools, [ADOT](platform/observability/) collectors, the [Argo CD](platform/argocd/) AppProject |
| [`gitops/`](gitops/) | Argo CD Applications, Helm values, and environment-specific manifests for [`dev`](gitops/environments/dev/) and [`prod`](gitops/environments/prod/) |
| [`docs/`](docs/) | Architecture diagrams (generated from code) and the deploy runbook |

## Known limitations and next steps

- **Orders events to SQS:** the queue exists, but the upstream chart has no SQS option, so orders uses
  in-memory messaging for now.
- **Pod density:** `t3.medium` nodes cap at 17 pods; VPC CNI prefix delegation would lift that.
- **Public entry point:** the storefront is reached by port-forward today; next is an ALB Ingress with
  an ACM certificate and ExternalDNS-managed records.
- **Amazon Managed Grafana:** supported but opt-in, since it needs IAM Identity Center on the account.

## License

[MIT](LICENSE). See [NOTICE.md](NOTICE.md) for third-party attribution.
