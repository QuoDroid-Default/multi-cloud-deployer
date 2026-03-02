# Azure Infrastructure Outputs

output "vpc_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "resource_group_name" {
  description = "Resource Group name"
  value       = azurerm_resource_group.main.name
}

output "instance_ids" {
  description = "VM instance IDs"
  value       = azurerm_linux_virtual_machine.app[*].id
}

output "instance_ips" {
  description = "VM instance private IPs"
  value       = azurerm_linux_virtual_machine.app[*].private_ip_address
}

output "instance_public_ips" {
  description = "VM instance public IPs (empty for private NICs)"
  value       = []
}

output "database_endpoint" {
  description = "PostgreSQL endpoint"
  value       = azurerm_postgresql_flexible_server.main.fqdn
  sensitive   = true
}

output "database_port" {
  description = "Database port"
  value       = 5432
}

output "database_name" {
  description = "Database name"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "database_password" {
  description = "Database password"
  value       = random_password.db.result
  sensitive   = true
}

output "cache_endpoint" {
  description = "Redis cache endpoint"
  value       = azurerm_redis_cache.main.hostname
}

output "cache_port" {
  description = "Cache port"
  value       = 6380
}

output "storage_bucket_names" {
  description = "Storage container names"
  value       = [for c in azurerm_storage_container.main : c.name]
}

output "storage_bucket_urls" {
  description = "Storage container URLs"
  value       = [for c in azurerm_storage_container.main : "https://${azurerm_storage_account.main.name}.blob.core.windows.net/${c.name}"]
}

output "cdn_domain" {
  description = "CDN domain name"
  value       = var.enable_cdn && length(azurerm_cdn_endpoint.main) > 0 ? azurerm_cdn_endpoint.main[0].fqdn : ""
}

output "dns_nameservers" {
  description = "DNS nameservers"
  value       = var.enable_dns && length(azurerm_dns_zone.main) > 0 ? azurerm_dns_zone.main[0].name_servers : []
}

output "deployment_summary" {
  description = "Deployment summary"
  value = {
    environment    = var.environment
    cloud_provider = "azure"
    region         = var.region
    instance_count = var.instance_count
    instance_type  = var.instance_type
  }
}
