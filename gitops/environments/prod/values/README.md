# GitOps: prod values

Helm values for each service, prod environment. **Unlike dev, no CI writes to these files.**
Promotion to prod is a deliberate manual action: open a PR that copies a specific,
already-proven dev image tag (from `../../dev/values/values-<service>.yaml`) into the matching
file here, reviewed like any other change. See `docs/runbooks/promote-to-prod.md` for the exact
steps. No automation wires this up on purpose — the manual PR is the gate.

Everything else (resource requests/limits, autoscaling, pod disruption budgets, topology spread,
capacity-type node selectors) currently mirrors dev's values — this is a new environment with no
production traffic history yet to size against.

## Expected contents

- `values-catalog.yaml`, `values-cart.yaml`, `values-checkout.yaml`, `values-orders.yaml`, `values-ui.yaml`

**Built in:** PR 12 — `feat/prod-env`

## Status

Implemented with placeholder image tags, matching dev's own starting point - promotion happens
once a dev tag has actually proven itself.
