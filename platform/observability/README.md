# Platform: observability

ADOT collector configuration: what each collector scrapes or receives, and where it forwards
traces, logs, and metrics. The AWS-side resources these depend on (the ADOT add-on, AMP, AMG)
are provisioned by `infrastructure/modules/observability`. The traces collector and the
`Instrumentation` CR carry no environment-specific values, so they stay here, shared across
every environment's ArgoCD instance.

`adot-collector-logs.yaml` and `adot-collector-metrics.yaml` are **not** here — the former
hardcodes a CloudWatch log group name, the latter an AMP remote-write endpoint, both of which
differ per environment. They live per-environment instead, at
`gitops/environments/<env>/platform/observability/`, and each environment's `platform.yaml`
Application syncs both this shared directory and its own env-specific one. See the ADR on shared
vs. environment-specific platform manifests (PR 13) for the full reasoning.

## Expected contents

- `namespace.yaml`
- `adot-collector-traces.yaml`
- `adot-instrumentation.yaml`

**Built in:** PR 10 — `feat/observability`. `adot-collector-logs.yaml` and
`adot-collector-metrics.yaml` moved out to per-environment `gitops/` directories in PR 12 —
`feat/prod-env`.

## Status

Manifests committed. Not yet applied - ArgoCD's `platform.yaml` Application (PR 8) picks these up
the same way it does Karpenter's. Each environment's `adot-collector-metrics.yaml` remote-write
endpoint is a placeholder until that environment's `70-observability` layer is actually applied.
