# GitOps

The desired state ArgoCD reconciles against: one Application per service, plus a `platform`
Application that syncs everything under `platform/`. The one bootstrap Application that owns every
other Application is created by `modules/argocd` via Terraform (`kubernetes_manifest`), not applied
by hand — that's the one deliberate exception to "everything here is GitOps-managed," and it's
Terraform-managed instead of a manual `kubectl apply` specifically so it's never a step a person can
forget.

## Structure

- `environments/<env>/applications/` — one ArgoCD Application per service, plus `platform.yaml`
- `environments/<env>/values/` — Helm values per service; CI updates the image tag here on every build
- `environments/<env>/manifests/` — anything that isn't a Helm chart or an Application (e.g. a
  SecretProviderClass, since ARNs differ per environment)

## Status

Implemented.
