# GitOps: dev values

Helm values for each service, dev environment. Each service's CI pipeline updates its `image.tag`
field here on every successful build — this file, not the chart's own default, is the source of
truth for what's actually running.

Autoscaling (PR 11): every service enables `autoscaling` (CPU-only targets - `ui`, `cart`, and
`orders` are JVM-based, and a memory target on a JVM service is a real trap, since heap doesn't
shrink back down after a load spike) and a percentage-based `podDisruptionBudget` so it tracks
`minReplicas`/`maxReplicas` automatically rather than needing a manual update if either changes.
`checkout` and `orders` pin to on-demand capacity via `nodeSelector`; `ui`, `catalog`, and `cart`
carry no capacity-type constraint, so Karpenter (PR 6) is free to place them on spot.

To actually demonstrate scale-out, the app repo already ships a purpose-built Artillery-based load
generator (`src/load-generator` - "useful for scenarios such as autoscaling, observability and
resiliency testing") rather than needing a custom script here.

## Expected contents

- `values-catalog.yaml`, `values-cart.yaml`, `values-checkout.yaml`, `values-orders.yaml`, `values-ui.yaml`

**Built in:** PR 8 — `feat/argocd` (image tag updates start arriving via PR 9's CI, autoscaling
values added in PR 11)

## Status

Implemented with placeholder image tags - PR 9's CI starts writing real ones.
