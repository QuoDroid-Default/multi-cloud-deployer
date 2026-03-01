# Database Module

locals {
  is_aws = var.cloud_provider == "aws"
}

resource "aws_db_subnet_group" "main" {
  count = local.is_aws ? 1 : 0

  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_db_instance" "main" {
  count = local.is_aws ? 1 : 0

  identifier     = "${var.environment}-db"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.database_name
  username = "dbadmin"
  password = random_password.db[0].result

  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = var.security_group_ids

  multi_az               = var.multi_az
  backup_retention_period = var.backup_retention_days
  storage_encrypted      = var.storage_encrypted
  skip_final_snapshot    = true

  tags = var.tags
}

resource "random_password" "db" {
  count = local.is_aws ? 1 : 0
  length  = 32
  special = true
}

resource "azurerm_postgresql_server" "main" {
  count = local.is_aws ? 0 : 1

  name                = "${var.environment}-db"
  location            = var.region
  resource_group_name = var.resource_group_name

  sku_name = var.instance_class

  storage_mb                   = var.allocated_storage * 1024
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.multi_az

  administrator_login          = "dbadmin"
  administrator_login_password = random_password.db_azure[0].result
  version                      = var.engine_version
  ssl_enforcement_enabled      = true

  tags = var.tags
}

resource "random_password" "db_azure" {
  count = local.is_aws ? 0 : 1
  length  = 32
  special = true
}
