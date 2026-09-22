resource "aws_db_subnet_group" "catalog" {
  name       = "${var.cluster_name}-catalog-mysql"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_security_group" "catalog" {
  name   = "${var.cluster_name}-catalog-mysql"
  vpc_id = var.vpc_id

  ingress {
    description     = "MySQL from EKS cluster"
    from_port       = 3306
    to_port         = 3306
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

resource "aws_db_instance" "catalog" {
  identifier                  = "${var.cluster_name}-catalog-mysql"
  engine                      = "mysql"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = 20
  storage_encrypted           = true
  db_subnet_group_name        = aws_db_subnet_group.catalog.name
  vpc_security_group_ids      = [aws_security_group.catalog.id]
  manage_master_user_password = true
  publicly_accessible         = false
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.cluster_name}-catalog-mysql-final"
  deletion_protection         = var.deletion_protection
  backup_retention_period     = var.backup_retention_period
  tags                        = merge(var.tags, { Environment = var.environment_name })
}

data "aws_iam_policy_document" "secret_read" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.catalog.master_user_secret[0].secret_arn]
  }
}

resource "aws_iam_role" "catalog" {
  name               = "${var.cluster_name}-catalog-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_policy" "secret_read" {
  name   = "${var.cluster_name}-catalog-secret-read"
  policy = data.aws_iam_policy_document.secret_read.json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "secret_read" {
  role       = aws_iam_role.catalog.name
  policy_arn = aws_iam_policy.secret_read.arn
}

resource "aws_eks_pod_identity_association" "catalog" {
  cluster_name    = var.cluster_name
  namespace       = "default"
  service_account = "catalog"
  role_arn        = aws_iam_role.catalog.arn
}
