#DATA SOURCE

data "aws_availability_zones" "available" {
  state = "available"

}

#LOCALS

locals {
  azs                  = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnet_cidrs  = { for k, az in local.azs : az => cidrsubnet(var.vpc_cidr, var.subnet_newbits, k) }
  private_subnet_cidrs = { for k, az in local.azs : az => cidrsubnet(var.vpc_cidr, var.subnet_newbits, k + length(local.azs)) }
}
