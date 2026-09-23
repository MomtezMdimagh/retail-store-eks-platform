# KMS key + CloudWatch log group

resource "aws_kms_key" "eks" {
  description         = "Envelope encryption for ${var.cluster_name} Kubernetes secrets"
  enable_key_rotation = true
  tags                = merge(var.tags, { Name = "${var.cluster_name}-eks-secrets", Environment = var.environment_name })
}


resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks.key_id
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = local.cluster_log_group_name
  retention_in_days = var.cluster_log_retention_days
  tags              = merge(var.tags, { Environment = var.environment_name })
}

# cluster IAM role

data "aws_iam_policy_document" "eks_cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# the cluster itself

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = merge(var.tags, { Environment = var.environment_name })

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
    aws_cloudwatch_log_group.eks_cluster,
  ]
}

# node group IAM role

data "aws_iam_policy_document" "eks_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  for_each   = toset(local.node_policy_arns)
  role       = aws_iam_role.eks_node.name
  policy_arn = each.value
}

# the node group itself

# A launch template purely to raise the IMDS hop limit to 2. AWS's default of 1 only allows
# processes running directly on the host to reach instance metadata - pod network namespaces are
# one hop further away, so with no launch template at all (the default for a managed node group),
# any pod trying to query IMDS (e.g. the LB Controller auto-discovering its VPC ID) gets
# "context deadline exceeded". Karpenter's EC2NodeClass already sets this correctly for the nodes
# it provisions - this was the one gap where the baseline group, created before Karpenter exists,
# was missed. No custom AMI here: leaving image_id unset means EKS still supplies the AMI that
# matches the node group's own `ami_type`, same as if there were no launch template at all.
resource "aws_launch_template" "baseline" {
  name_prefix = "${var.cluster_name}-baseline-"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.node_disk_size
      volume_type = "gp3"
      encrypted   = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.cluster_name}-baseline", Environment = var.environment_name })
  }

  tags = merge(var.tags, { Environment = var.environment_name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "baseline" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-baseline"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_instance_types
  capacity_type  = var.node_capacity_type
  ami_type       = "AL2023_x86_64_STANDARD"

  launch_template {
    id      = aws_launch_template.baseline.id
    version = aws_launch_template.baseline.latest_version
  }

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(var.tags, { Name = "${var.cluster_name}-baseline", Environment = var.environment_name })

  depends_on = [aws_iam_role_policy_attachment.eks_node]
}
