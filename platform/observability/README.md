# Platform: observability

ADOT collector configuration: what each collector scrapes or receives, and where it forwards
traces, logs, and metrics. The AWS-side resources these depend on (the ADOT add-on, AMP, AMG)
are provisioned by `infrastructure/modules/observability`.

## Expected contents

- `namespace.yaml`
- `adot-collector-traces.yaml`
- `adot-collector-logs.yaml`
- `adot-collector-metrics.yaml`
- `adot-instrumentation.yaml`

**Built in:** PR 10 — `feat/observability`

## Status

Manifests committed. Not yet applied - ArgoCD's `platform.yaml` Application (PR 8) picks these up
the same way it does Karpenter's. `adot-collector-metrics.yaml`'s remote-write endpoint is a
placeholder until `infrastructure/live/dev/70-observability` is actually applied.
