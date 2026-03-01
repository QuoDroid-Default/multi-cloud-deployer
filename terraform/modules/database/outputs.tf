output "endpoint" {
  value = var.cloud_provider == "aws" ? (length(aws_db_instance.main) > 0 ? aws_db_instance.main[0].endpoint : "") : (length(azurerm_postgresql_server.main) > 0 ? azurerm_postgresql_server.main[0].fqdn : "")
}

output "port" {
  value = var.cloud_provider == "aws" ? 5432 : 5432
}

output "database_name" {
  value = var.database_name
}

output "password" {
  value     = var.cloud_provider == "aws" ? random_password.db[0].result : random_password.db_azure[0].result
  sensitive = true
}
