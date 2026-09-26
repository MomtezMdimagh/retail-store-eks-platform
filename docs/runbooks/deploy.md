# Runbook: deploy `dev` for real

The exact, ordered steps for the **first real apply** of this platform - everything up to this
point has been build/validate-only. Follow this top to bottom; each step tells you what to expect
before moving on. This is also the shot list for the demo recording - the checkpoints marked
**🎥** are natural places to start/stop a clip.

Everything here targets `dev`. `prod` is not touched.

## 0. Prerequisites

- AWS credentials configured locally (`aws sts get-caller-identity` returns your account).
- `kubectl` (already installed here), `aws` CLI v2 (already installed here).
- `helm` v3 - **not installed on this machine yet**. Install it (e.g.
  `winget install Helm.Helm`) before step 2.
- Confirm nothing but `bootstrap/` has ever been applied: every `infrastructure/live/dev/*`
  directory's `.terraform/terraform.tfstate` is just the backend pointer, not real resource state
  (if you're not sure, `terraform state list` in each should come back empty).
- Have `retail-store-sample-app` cloned as a sibling checkout, on `main`, up to date.

## 1. Rename the vendored charts to match our ECR layout

`bootstrap/ecr.tf` created one ECR repository per service at `charts/<service>` (e.g.
`charts/cart`). Every chart's `Chart.yaml` currently names itself something like
`retail-store-sample-cart-chart` - Helm always pushes a chart under its own `Chart.yaml` name, so
pushed as-is it would land at `charts/retail-store-sample-cart-chart`, not `charts/cart`, and
ArgoCD's Applications (which reference `charts/cart` explicitly) would never find it.

In `retail-store-sample-app`, for each of `cart`, `catalog`, `checkout`, `orders`, `ui`, edit
`src/<service>/chart/Chart.yaml`'s `name:` field to just `<service>` (e.g. `name: cart`). Commit
this in the app fork - it's a legitimate, permanent fix to match this platform's ECR layout, not a
one-off hack to undo later.

## 2. Package and push the 5 charts once 🎥

Nothing in either repo's CI publishes a chart yet (the `targetRevision: "0.1.0"` comment about
"PR 9's CI pushes a real chart version" was aspirational, never actually built). This is a
one-time manual step until that automation exists.

```bash
aws ecr get-login-password --region us-east-1 \
  | helm registry login --username AWS --password-stdin 652197205931.dkr.ecr.us-east-1.amazonaws.com

cd /path/to/retail-store-sample-app
for svc in cart catalog checkout orders ui; do
  helm package "src/$svc/chart" --version 0.1.0 --app-version 0.1.0 -d /tmp/charts
  helm push "/tmp/charts/$svc-0.1.0.tgz" "oci://652197205931.dkr.ecr.us-east-1.amazonaws.com/charts"
done
```

**Verify before moving on**: `aws ecr describe-images --repository-name charts/cart` (and the
other 4) each show one image tagged `0.1.0`.

Two details confirmed the hard way on the first real run: `helm push` takes the registry path
*without* the chart name (it appends the chart's own `Chart.yaml` name, which is why step 1's
rename matters), and ArgoCD does the same when pulling - each Application's `repoURL` is
`<registry>/charts` and its `chart:` field supplies the final `<service>` segment. Putting
`charts/<service>` in `repoURL` makes ArgoCD look for `charts/<service>/<service>`, which
doesn't exist.

## 3. Apply the 7 layers, in order

For each layer `10-network`, `20-cluster`, `30-addons`, `40-karpenter`, `50-data-plane`,
`60-argocd`, `70-observability`:

```bash
cd infrastructure/live/dev/<layer>
terraform init -backend-config=backend.hcl
terraform apply -var-file=dev.tfvars
```

Read the plan before typing `yes` each time - same discipline as every `terraform plan` this
project has already run for real, just with an apply behind it now.

**After `50-data-plane` applies 🎥**, before continuing to `60-argocd`:

```bash
cd infrastructure/live/dev/50-data-plane
terraform output catalog_endpoint
terraform output catalog_secret_arn
terraform output orders_endpoint
terraform output orders_secret_arn
terraform output checkout_endpoint
terraform output cart_table_name
```

Fill in every `<FILL IN AFTER 50-data-plane APPLIES: ...>` placeholder this runbook's Phase 0 left
behind (`grep -rn "FILL IN AFTER" gitops/environments/dev/` finds all of them):

- `gitops/environments/dev/values/values-catalog.yaml` - `app.persistence.endpoint`
- `gitops/environments/dev/values/values-orders.yaml` - `app.persistence.endpoint`
- `gitops/environments/dev/values/values-checkout.yaml` - `app.persistence.redis.endpoint`
  (append `:6379` - already noted in the file, `checkout_endpoint`'s value has no port suffix)
- `gitops/environments/dev/values/values-cart.yaml` - `app.persistence.dynamodb.tableName`
- `gitops/environments/dev/manifests/secretproviderclass-catalog.yaml` - the `objectName` ARN
- `gitops/environments/dev/manifests/secretproviderclass-orders.yaml` - the `objectName` ARN

Before trusting the two `SecretProviderClass` files' `jmesPath` key names
(`username`/`password`), confirm the real secret's shape once:
`aws secretsmanager get-secret-value --secret-id <catalog_secret_arn> --query SecretString --output text | python -m json.tool`
- this project's assumption is AWS's standard RDS-managed-password JSON shape, but confirm it
  empirically rather than trust it blindly, same as the OCI chart path in step 2.

Commit and push these six files, then continue to `60-argocd`.

## 4. Configure kubectl and confirm ArgoCD is alive

```bash
aws eks update-kubeconfig --name retail-store-eks-dev --region us-east-1
kubectl get applications -n argocd
```

The bootstrap Application (created by Terraform in `60-argocd`, the one deliberate
`kubectl apply` exception this project has always documented) should already be reconciling
everything under `gitops/environments/dev/`.

## 5. Get real images built

Push a trivial commit to `retail-store-sample-app` (touching any path under `src/<service>/`
triggers that service's build via the existing path filters) or re-run the workflow manually from
the Actions tab. Confirm in ECR: `aws ecr describe-images --repository-name retail-store/catalog`
shows a `sha-xxxxxxx` tag.

The GitHub App for automated cross-repo tag write-back was never configured (not worth setting up
for a one-time test) - so the CI job's last step (bumping `image.tag` in this repo) will fail.
That's expected. Manually bump `image.tag` in each of the 5 `values-<service>.yaml` files to the
real `sha-` tag from ECR, commit, push.

## 6. Watch ArgoCD sync 🎥

```bash
kubectl get applications -n argocd -w
```

Every Application (`ui`, `catalog`, `cart`, `checkout`, `orders`, `platform`, `manifests`) should
move to `Synced`/`Healthy`. Get the initial admin password
(`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)
and either port-forward (`kubectl -n argocd port-forward svc/argocd-server 8080:443`) or find the
LB hostname to actually see the UI.

**If `catalog`/`orders` pods are stuck, not `checkout`/`cart`**: check
`kubectl get secret catalog-db orders-db` exist first - they're only populated once
`secret-sync-helper-catalog`/`-orders` are themselves running (the CSI driver only syncs while
something mounts the `SecretProviderClass`; see the comments in
`gitops/environments/dev/manifests/secret-sync-helper.yaml`).

## 7. Verify it's real, not defaults

Quick sanity check before the full exercise below: `kubectl exec` into the catalog pod and confirm
`env | grep RETAIL_CATALOG_PERSISTENCE` shows `mysql`, not `in-memory`.

## 8. Exercise it end to end and record 🎥

Get the `ui` service's URL (LoadBalancer hostname via
`kubectl get svc <ui-service-name> -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`, or
port-forward it) and, on camera:

1. **Browse → add to cart → checkout → place an order.** This is the one thing that proves
   `catalog-mysql`, `cart-dynamodb`, `checkout-redis`, and `orders-postgres` all actually work
   through Pod Identity - not a mock, not in-memory.
2. **Trigger real autoscaling.** Run the app repo's built-in Artillery load generator
   (`src/load-generator`) against the UI URL, then `kubectl get nodes -w` in a second pane to
   watch Karpenter actually provision a node in response to the resulting HPA scale-out.
3. **If you can catch it, a spot interruption.** Whether one happens naturally during the
   recording window or you manually terminate a spot-provisioned node
   (`aws ec2 terminate-instances --instance-ids <id>`), watch the SQS/EventBridge pipeline from
   PR 6 drain it gracefully - the one PR 6 behavior nobody can verify by just reading the code.
4. **The observability payoff.** Check metrics landing in AMP and logs landing in CloudWatch under
   the log group `infrastructure/live/dev/70-observability` created.

This is also the shot list for the LinkedIn video: hook → the architecture diagram from the root
`README.md` → sped-up ArgoCD sync (step 6) → the live checkout flow (above) → whichever of
Karpenter-scaling or the spot-interruption drain you actually captured cleanly → a close card
pointing at the repo. Silent, captioned, no voiceover needed.

## 9. Tear down

Exact reverse order (`70-observability` → `10-network`), `terraform destroy -var-file=dev.tfvars`
in each layer. Note anything `destroy` doesn't clean up by itself (versioned S3 objects, ECR
repositories that still hold images) - that becomes `docs/runbooks/teardown.md`, written from what
actually happened during this teardown rather than guessed in advance.
