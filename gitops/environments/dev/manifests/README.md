# GitOps: dev manifests

![dev manifests diagram (planned)](../../../../docs/diagrams/generated/dev-manifests.png)

Anything needed by the running services that isn't a Helm chart value or an ArgoCD Application -
planned: SecretProviderClass resources mapping Secrets Manager entries into Kubernetes secrets,
since their ARNs differ per environment and aren't part of the upstream charts.

## Expected contents

- `secretproviderclass-catalog.yaml`, `secretproviderclass-cart.yaml`,
  `secretproviderclass-checkout.yaml`, `secretproviderclass-orders.yaml`

**Built in:** PR 8 — `feat/argocd`

## Status

Not yet implemented.
