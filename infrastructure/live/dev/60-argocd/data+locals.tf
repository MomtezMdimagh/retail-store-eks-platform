data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-us-east-1-c40pku"
    key    = "cluster/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}
