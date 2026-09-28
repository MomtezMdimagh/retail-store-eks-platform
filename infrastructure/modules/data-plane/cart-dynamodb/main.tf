resource "aws_dynamodb_table" "cart" {
  name         = "${var.cluster_name}-cart-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  # The cart service looks a customer's items up through this index, by name - it's part of the
  # table design the upstream application assumes, not an optimisation, so without it every request
  # fails with AccessDenied/ResourceNotFound and the pods crash-loop.
  global_secondary_index {
    name            = "idx_global_customerId"
    hash_key        = "customerId"
    projection_type = "ALL"
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
    resources = [aws_dynamodb_table.cart.arn, "${aws_dynamodb_table.cart.arn}/index/*"] # Query on an index is authorised against the index ARN, not the table's
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
