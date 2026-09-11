locals {
  services = ["ui", "catalog", "cart", "checkout", "orders"]
}

resource "aws_ecr_repository" "images" {
  for_each             = toset(local.services)
  name                 = "retail-store/${each.key}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "retail-store-${each.key}"
    Environment = var.environment_name
    Project     = "retail-store-eks-platform"
    Purpose     = "container-images"
  }
}


resource "aws_ecr_repository" "charts" {
  for_each             = toset(local.services)
  name                 = "charts/${each.key}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "retail-store-helm-charts-${each.key}"
    Environment = var.environment_name
    Project     = "retail-store-eks-platform"
    Purpose     = "helm-charts"
  }

}
