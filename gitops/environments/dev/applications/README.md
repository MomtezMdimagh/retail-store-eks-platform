# GitOps: dev applications

One ArgoCD Application per service, plus `platform.yaml` which syncs everything under
`platform/karpenter` and `platform/observability`. Auto-sync with prune and self-heal enabled —
drift between the cluster and this directory corrects itself.

## Expected contents

- `platform.yaml`
- `catalog.yaml`, `cart.yaml`, `checkout.yaml`, `orders.yaml`, `ui.yaml`

**Built in:** PR 8 — `feat/argocd`

## Status

Implemented.
