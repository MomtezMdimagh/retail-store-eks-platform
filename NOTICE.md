# Notice

This repository contains original infrastructure-as-code, GitOps configuration, and operational
documentation authored by Momtez Mdimagh. **No application source code is vendored here.**

## Application under management

The workload this platform deploys is Amazon's open-source retail store sample application:

- Upstream: https://github.com/aws-containers/retail-store-sample-app
- Fork used here (adds CI/CD, pinned at `v1.3.0`): https://github.com/MomtezMdimagh/retail-store-sample-app

```
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
```

Licensed under the MIT License — see upstream's `LICENSE` file for full terms.

## This repository

Everything under `bootstrap/`, `infrastructure/`, `platform/`, `gitops/`, and `docs/` — the
Terraform modules, cluster add-on configuration, Karpenter NodePools, ArgoCD manifests, Helm
values, and documentation — is original work, licensed under the MIT License (see `LICENSE`).
