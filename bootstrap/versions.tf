terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

  # Actual bucket/key/region come from backend.hcl via -backend-config, never hardcoded here.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
