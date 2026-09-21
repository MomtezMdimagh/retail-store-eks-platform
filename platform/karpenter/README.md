# Platform: karpenter

Node provisioning policy, applied by ArgoCD: an EC2NodeClass defining what a node looks like, and
two NodePools — one on-demand, one spot — so workloads that tolerate interruption run on
significantly cheaper capacity while critical ones stay on-demand.

## Expected contents

- `ec2nodeclass.yaml`
- `nodepool-ondemand.yaml`
- `nodepool-spot.yaml`

**Built in:** PR 6 — `feat/karpenter`

## Status

Manifests committed. Not yet applied - ArgoCD (PR 8) is what will actually apply these to the
cluster; per this repo's own convention, `platform/` is never `kubectl apply`-ed directly.
