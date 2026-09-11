# GitOps: dev values

Helm values for each service, dev environment. Each service's CI pipeline updates its `image.tag`
field here on every successful build — this file, not the chart's own default, is the source of
truth for what's actually running.

## Expected contents

- `values-catalog.yaml`, `values-cart.yaml`, `values-checkout.yaml`, `values-orders.yaml`, `values-ui.yaml`

**Built in:** PR 8 — `feat/argocd` (image tag updates start arriving via PR 9's CI)

## Status

Not yet implemented.
