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

Not yet implemented.
