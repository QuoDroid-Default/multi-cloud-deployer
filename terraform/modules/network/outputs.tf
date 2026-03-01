output "vpc_id" {
  value = var.cloud_provider == "aws" ? (length(aws_vpc.main) > 0 ? aws_vpc.main[0].id : "") : (length(azurerm_virtual_network.main) > 0 ? azurerm_virtual_network.main[0].id : "")
}

output "public_subnet_ids" {
  value = var.cloud_provider == "aws" ? aws_subnet.public[*].id : azurerm_subnet.public[*].id
}

output "private_subnet_ids" {
  value = var.cloud_provider == "aws" ? aws_subnet.private[*].id : azurerm_subnet.private[*].id
}

output "app_security_group_id" {
  value = var.cloud_provider == "aws" ? (length(aws_security_group.app) > 0 ? aws_security_group.app[0].id : "") : ""
}

output "db_security_group_id" {
  value = var.cloud_provider == "aws" ? (length(aws_security_group.db) > 0 ? aws_security_group.db[0].id : "") : ""
}

output "cache_security_group_id" {
  value = var.cloud_provider == "aws" ? (length(aws_security_group.cache) > 0 ? aws_security_group.cache[0].id : "") : ""
}

output "resource_group_name" {
  value = var.cloud_provider == "azure" ? (length(azurerm_resource_group.main) > 0 ? azurerm_resource_group.main[0].name : "") : ""
}
