resource "aws_elasticache_subnet_group" "checkout" {
  name       = "${var.cluster_name}-checkout-redis"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "checkout" {
  name   = "${var.cluster_name}-checkout-redis"
  vpc_id = var.vpc_id

  ingress {
    description     = "Redis from EKS cluster"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Environment = var.environment_name })
}

resource "random_password" "auth" {
  length  = 32
  special = false
}

resource "aws_elasticache_replication_group" "checkout" {
  replication_group_id       = "${var.cluster_name}-checkout-redis"
  description                = "Redis cache for the checkout service"
  engine                     = "redis"
  engine_version             = var.engine_version
  node_type                  = var.node_type
  num_cache_clusters         = 1
  parameter_group_name       = "default.redis7"
  subnet_group_name          = aws_elasticache_subnet_group.checkout.name
  security_group_ids         = [aws_security_group.checkout.id]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.auth.result
  tags                       = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_secretsmanager_secret" "checkout" {
  name = "${var.cluster_name}-checkout-redis-auth"
  tags = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_secretsmanager_secret_version" "checkout" {
  secret_id = aws_secretsmanager_secret.checkout.id
  secret_string = jsonencode({
    auth_token = random_password.auth.result
    endpoint   = aws_elasticache_replication_group.checkout.primary_endpoint_address
    port       = 6379
  })
}

data "aws_iam_policy_document" "checkout" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.checkout.arn]
  }
}

resource "aws_iam_role" "checkout" {
  name               = "${var.cluster_name}-checkout-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_policy" "checkout" {
  name   = "${var.cluster_name}-checkout-secret-read"
  policy = data.aws_iam_policy_document.checkout.json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "checkout" {
  role       = aws_iam_role.checkout.name
  policy_arn = aws_iam_policy.checkout.arn
}

resource "aws_eks_pod_identity_association" "checkout" {
  cluster_name    = var.cluster_name
  namespace       = "default"
  service_account = "checkout"
  role_arn        = aws_iam_role.checkout.arn
}
