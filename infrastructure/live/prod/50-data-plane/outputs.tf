output "catalog_secret_arn" {
  value = module.catalog_mysql.secret_arn
}

output "catalog_endpoint" {
  value = module.catalog_mysql.endpoint
}

output "orders_secret_arn" {
  value = module.orders_postgres.secret_arn
}

output "orders_endpoint" {
  value = module.orders_postgres.endpoint
}

output "orders_queue_url" {
  value = module.orders_postgres.queue_url
}

output "cart_table_name" {
  value = module.cart_dynamodb.table_name
}

output "checkout_secret_arn" {
  value = module.checkout_redis.secret_arn
}

output "checkout_endpoint" {
  value = module.checkout_redis.endpoint
}
