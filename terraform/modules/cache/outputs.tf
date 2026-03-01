output "endpoint" {
  value = var.cloud_provider == "aws" ? (length(aws_elasticache_cluster.main) > 0 ? aws_elasticache_cluster.main[0].cache_nodes[0].address : "") : (length(azurerm_redis_cache.main) > 0 ? azurerm_redis_cache.main[0].hostname : "")
}

output "port" {
  value = 6379
}
