# Platform: observability

ADOT collector configuration: what each collector scrapes or receives, and where it forwards
traces, logs, and metrics. The AWS-side resources these depend on (the ADOT add-on, AMP, AMG)
are provisioned by `infrastructure/modules/observability`.

## Expected contents

- `adot-collector-traces.yaml`
- `adot-collector-logs.yaml`
- `adot-collector-metrics.yaml`
- `adot-instrumentation.yaml`

**Built in:** PR 10 — `feat/observability`

## Status

Not yet implemented.
