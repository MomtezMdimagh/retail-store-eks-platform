data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-us-east-1-c40pku"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-us-east-1-c40pku"
    key    = "cluster/terraform.tfstate"
    region = "us-east-1"
  }
}
