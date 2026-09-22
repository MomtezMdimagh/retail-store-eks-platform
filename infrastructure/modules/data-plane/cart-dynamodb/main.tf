resource "aws_dynamodb_table" "cart" {
  name         = "${var.cluster_name}-cart-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.tags, { Environment = var.environment_name })
}

data "aws_iam_policy_document" "cart" {
  statement {
    actions = [
      "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem",
      "dynamodb:DeleteItem", "dynamodb:Query",
    ]
    resources = [aws_dynamodb_table.cart.arn]
  }
}

resource "aws_iam_role" "cart" {
  name               = "${var.cluster_name}-cart-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
  tags               = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_policy" "cart" {
  name   = "${var.cluster_name}-cart-dynamodb"
  policy = data.aws_iam_policy_document.cart.json
  tags   = merge(var.tags, { Environment = var.environment_name })
}

resource "aws_iam_role_policy_attachment" "cart" {
  role       = aws_iam_role.cart.name
  policy_arn = aws_iam_policy.cart.arn
}

resource "aws_eks_pod_identity_association" "cart" {
  cluster_name    = var.cluster_name
  namespace       = "default"
  service_account = "cart"
  role_arn        = aws_iam_role.cart.arn
}
