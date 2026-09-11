# retail-store-eks-platform

Platform-engineering project: EKS on AWS with layered Terraform, Karpenter, ArgoCD GitOps, and
ADOT/AMP/AMG observability. Application source lives in a separate repo:
github.com/MomtezMdimagh/retail-store-sample-app

## Structure

- `bootstrap/` — run-once, by hand: S3 state backend, GitHub OIDC deploy role, ECR repositories
- `infrastructure/modules/` — all Terraform logic lives here
- `infrastructure/live/<env>/<NN-layer>/` — thin roots: a module block, backend config, and
  tfvars only. No inline resources.
- `platform/` — cluster-level manifests (Karpenter NodePools, ADOT collectors); ArgoCD-managed,
  never `kubectl apply`-ed directly except for the one-time app-of-apps bootstrap
- `gitops/` — ArgoCD app-of-apps, per-service Applications, and Helm values per environment
- `docs/` — architecture, ADRs, runbooks, cost tracking, teardown checklist

## Conventions

- Terraform filenames: `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`. Never numbered
  prefixes like `c1_` or `c14-02-`.
- Backend config is always passed via `-backend-config=backend.hcl`; never hardcode a bucket
  name inside `versions.tf`.
- Use S3 native state locking (`use_lockfile = true`). No DynamoDB lock table.
- Zero AWS account IDs, ARNs, hosted zone IDs, or domain names in committed code. Non-secret
  values go in `tfvars` or GitHub Actions **variables**; secrets go in GitHub Actions **secrets**
  or AWS Secrets Manager — never in a committed file.
- Helm charts are consumed as OCI artifacts from our own ECR. No third-party chart repositories.
- Conventional commits (`feat:`, `fix:`, `docs:`, `chore:`). Squash-merge. One pull request per
  layer, following the build order in `README.md`.
- `NOTES.md` (gitignored) holds working notes that must never be published; do not recreate its
  content elsewhere in the tree.
- Every module, and every folder under `platform/` and `gitops/`, carries its own `README.md`
  stating purpose, expected contents, and status. For Terraform modules this README also carries
  `terraform-docs` markers (`<!-- BEGIN_TF_DOCS -->` / `<!-- END_TF_DOCS -->`) — once a module has
  real `.tf` files, the pre-commit hook fills that section automatically; don't hand-edit inside it.
