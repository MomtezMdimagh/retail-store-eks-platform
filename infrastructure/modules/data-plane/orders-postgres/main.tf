resource "aws_db_subnet_group" "orders" {
  name       = "${var.cluster_name}-orders-postgres"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_security_group" "orders" {
  name   = "${var.cluster_name}-orders-postgres"
  vpc_id = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS cluster"
    from_port       = 5432
    to_port         = 5432
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

resource "aws_db_instance" "orders" {
  identifier                  = "${var.cluster_name}-orders-postgres"
  engine                      = "postgres"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = 20
  storage_encrypted           = true
  db_subnet_group_name        = aws_db_subnet_group.orders.name
  vpc_security_group_ids      = [aws_security_group.orders.id]
  username                    = "orders"
  manage_master_user_password = true
  publicly_accessible         = false
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.cluster_name}-orders-postgres-final"
  deletion_protection         = var.deletion_protection
  backup_retention_period     = var.backup_retention_period
  tags                        = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.cluster_name}-orders-dlq"
  message_retention_seconds = 1209600 # 14 days
  kms_master_key_id         = "alias/aws/sqs"
  tags                      = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_sqs_queue" "orders" {
  name                       = "${var.cluster_name}-orders"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 30
  receive_wait_time_seconds  = 10
  kms_master_key_id          = "alias/aws/sqs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })

  tags = merge(var.tags, { Environment = var.environment_name })
}

data "aws_iam_policy_document" "orders" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.orders.master_user_secret[0].secret_arn]
  }

  statement {
    actions   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = [aws_sqs_queue.orders.arn]
  }
}

resource "aws_iam_role" "orders" {
  name               = "${var.cluster_name}-orders-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_policy" "orders" {
  name   = "${var.cluster_name}-orders-data-plane"
  policy = data.aws_iam_policy_document.orders.json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "orders" {
  role       = aws_iam_role.orders.name
  policy_arn = aws_iam_policy.orders.arn
}

resource "aws_eks_pod_identity_association" "orders" {
  cluster_name    = var.cluster_name
  namespace       = "default"
  service_account = "orders"
  role_arn        = aws_iam_role.orders.arn
}
