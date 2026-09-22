environment_name          = "prod"
cluster_name              = "retail-store-eks-prod"
cluster_version           = "1.36"
upstream_state_key_prefix = "prod/"

# Tightened from dev's ["0.0.0.0/0"] - this is a documentation-only placeholder (RFC 5737
# TEST-NET-3), not a real address. Replace with the actual CIDR you'll manage this cluster from
# before ever applying this layer.
cluster_endpoint_public_access_cidrs = ["203.0.113.0/24"]

tags = {
  Terraform = "true"
  Project   = "retail-store-eks-platform"
}
