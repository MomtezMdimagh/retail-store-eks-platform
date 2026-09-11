# Infrastructure

All Terraform for the platform, split into two layers:

- **`modules/`** — reusable building blocks. All resource logic lives here. A module knows nothing
  about which environment it's deployed into.
- **`live/<env>/<NN-layer>/`** — thin per-environment roots. Each one is a module call plus backend
  configuration and a `.tfvars` file — no resources defined directly. Layers are numbered by
  dependency order (network before cluster, cluster before workloads) and applied in that order.

## Status

`modules/` is being built out progressively — see each module's own README for what it owns and
which PR delivers it. `live/` appears alongside the first module that needs it.
