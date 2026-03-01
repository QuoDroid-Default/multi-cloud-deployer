# Cache Module

locals {
  is_aws = var.cloud_provider == "aws"
}

resource "aws_elasticache_subnet_group" "main" {
  count = local.is_aws ? 1 : 0

  name       = "${var.environment}-cache-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_elasticache_cluster" "main" {
  count = local.is_aws ? 1 : 0

  cluster_id           = "${var.environment}-cache"
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = "default.redis7"
  engine_version       = var.engine_version
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main[0].name
  security_group_ids   = var.security_group_ids

  tags = var.tags
}

resource "azurerm_redis_cache" "main" {
  count = local.is_aws ? 0 : 1

  name                = "${var.environment}-cache"
  location            = var.region
  resource_group_name = var.resource_group_name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"

  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  tags = var.tags
}
