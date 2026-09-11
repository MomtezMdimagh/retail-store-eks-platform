# GitOps

The desired state ArgoCD reconciles against: one Application per service, plus a `platform`
Application that syncs everything under `platform/`. `app-of-apps.yaml` is the single manifest
ever applied by hand — it owns every other Application, so nothing else needs a manual `kubectl
apply`.

## Structure

- `app-of-apps.yaml` — the one manifest you apply manually, once
- `environments/<env>/applications/` — one ArgoCD Application per service, plus `platform.yaml`
- `environments/<env>/values/` — Helm values per service; CI updates the image tag here on every build
- `environments/<env>/manifests/` — anything that isn't a Helm chart or an Application (e.g. a
  SecretProviderClass, since ARNs differ per environment)

## Status

Not yet implemented.
