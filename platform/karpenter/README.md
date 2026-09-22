# Platform: karpenter

Node provisioning policy, applied by ArgoCD: two NodePools — one on-demand, one spot — so
workloads that tolerate interruption run on significantly cheaper capacity while critical ones
stay on-demand. Both reference an `EC2NodeClass` named `default` by logical name only, so they're
genuinely environment-agnostic and stay here.

The `EC2NodeClass` itself is **not** here — it hardcodes a cluster name, VPC tags, and a
Karpenter node role name, all of which differ per environment. It lives per-environment instead,
at `gitops/environments/<env>/platform/karpenter/ec2nodeclass.yaml`, and each environment's
`platform.yaml` Application syncs both this shared directory and its own env-specific one. See
the ADR on shared vs. environment-specific platform manifests (PR 13) for the full reasoning.

## Expected contents

- `nodepool-ondemand.yaml`
- `nodepool-spot.yaml`

**Built in:** PR 6 — `feat/karpenter`. `ec2nodeclass.yaml` moved out to per-environment
`gitops/` directories in PR 12 — `feat/prod-env`.

## Status

Manifests committed. Not yet applied - ArgoCD (PR 8) is what will actually apply these to the
cluster; per this repo's own convention, `platform/` is never `kubectl apply`-ed directly.
