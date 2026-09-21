# Platform: argocd

The AppProject that scopes what the Applications in `gitops/` are allowed to deploy. ArgoCD's own
installation is Terraform-managed (`infrastructure/modules/argocd`), not documented here as manual
steps - this folder only holds the one manifest that has to live inside `platform/` so the
`gitops/environments/dev/applications/platform.yaml` Application (which recursively syncs
everything under `platform/`) picks it up along with Karpenter's and observability's manifests.

## Expected contents

- `appproject-retail-store.yaml`

**Built in:** PR 8 — `feat/argocd`

## Status

Implemented.
