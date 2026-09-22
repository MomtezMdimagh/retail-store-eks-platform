# GitOps: dev platform

The `platform/` manifests that are genuinely coupled to this environment — a cluster name, VPC
tags, a Karpenter node role name, or an AMP remote-write endpoint — and so can't live in the
shared `platform/` directory at the repo root. Synced by this environment's `platform.yaml`
Application as a second source, alongside the shared directory.

## Expected contents

- `karpenter/ec2nodeclass.yaml`
- `observability/adot-collector-logs.yaml`, `observability/adot-collector-metrics.yaml`

**Built in:** PR 6 — `feat/karpenter` and PR 10 — `feat/observability` (as part of the shared
`platform/` directory at the time); moved here in PR 12 — `feat/prod-env`, once a second
environment made the coupling a real bug rather than a cosmetic one.

## Status

Implemented.
