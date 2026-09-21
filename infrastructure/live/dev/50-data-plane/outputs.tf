output "catalog_secret_arn" {
  value = module.catalog_mysql.secret_arn
}

output "orders_secret_arn" {
  value = module.orders_postgres.secret_arn
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
