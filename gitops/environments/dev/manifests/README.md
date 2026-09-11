# GitOps: dev manifests

Anything needed by the running services that isn't a Helm chart value or an ArgoCD Application.
Currently just the SecretProviderClass resources that map AWS Secrets Manager entries into
Kubernetes secrets — these aren't part of the upstream charts, and their ARNs differ per
environment, so they live here rather than in a shared chart.

## Expected contents

- `secretproviderclass-catalog.yaml`, `secretproviderclass-cart.yaml`,
  `secretproviderclass-checkout.yaml`, `secretproviderclass-orders.yaml`

**Built in:** PR 8 — `feat/argocd`

## Status

Not yet implemented.
