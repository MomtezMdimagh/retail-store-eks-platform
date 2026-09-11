# Platform

Cluster-level Kubernetes manifests: node provisioning policy and the observability collector
configuration. Everything here is managed by ArgoCD, not applied by hand — the only manual
`kubectl apply` in this project is the one-time app-of-apps bootstrap in `gitops/`.

## Expected contents

- `karpenter/` — node provisioning: EC2NodeClass and NodePools (on-demand, spot)
- `observability/` — ADOT collector configuration and instrumentation
- `argocd/` — installation notes and the AppProject definition

## Status

Not yet implemented.
