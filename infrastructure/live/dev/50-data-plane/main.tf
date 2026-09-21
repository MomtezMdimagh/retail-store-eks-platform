module "catalog_mysql" {
  source = "../../../modules/data-plane/catalog-mysql"

  environment_name          = var.environment_name
  cluster_name              = var.cluster_name
  vpc_id                    = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids        = data.terraform_remote_state.network.outputs.private_subnet_ids
  cluster_security_group_id = data.terraform_remote_state.cluster.outputs.cluster_security_group_id
  engine_version            = var.mysql_engine_version
  tags                      = var.tags
}

module "orders_postgres" {
  source = "../../../modules/data-plane/orders-postgres"

  environment_name          = var.environment_name
  cluster_name              = var.cluster_name
  vpc_id                    = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids        = data.terraform_remote_state.network.outputs.private_subnet_ids
  cluster_security_group_id = data.terraform_remote_state.cluster.outputs.cluster_security_group_id
  engine_version            = var.postgres_engine_version
  tags                      = var.tags
}

module "cart_dynamodb" {
  source = "../../../modules/data-plane/cart-dynamodb"

  environment_name = var.environment_name
  cluster_name     = var.cluster_name
  tags             = var.tags
}

module "checkout_redis" {
  source = "../../../modules/data-plane/checkout-redis"

  environment_name          = var.environment_name
  cluster_name              = var.cluster_name
  vpc_id                    = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids        = data.terraform_remote_state.network.outputs.private_subnet_ids
  cluster_security_group_id = data.terraform_remote_state.cluster.outputs.cluster_security_group_id
  engine_version            = var.redis_engine_version
  tags                      = var.tags
}
