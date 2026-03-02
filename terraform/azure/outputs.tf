# Azure Infrastructure Outputs

output "vpc_id" {
  description = "Virtual Network ID"
  value       = module.network.vpc_id
}

output "instance_ids" {
  description = "VM instance IDs"
  value       = module.compute.instance_ids
}

output "instance_ips" {
  description = "VM instance private IPs"
  value       = module.compute.instance_private_ips
}

output "instance_public_ips" {
  description = "VM instance public IPs"
  value       = module.compute.instance_public_ips
}

output "database_endpoint" {
  description = "PostgreSQL endpoint"
  value       = module.database.endpoint
  sensitive   = true
}

output "database_port" {
  description = "Database port"
  value       = module.database.port
}

output "database_name" {
  description = "Database name"
  value       = module.database.database_name
}

output "cache_endpoint" {
  description = "Redis cache endpoint"
  value       = module.cache.endpoint
}

output "cache_port" {
  description = "Cache port"
  value       = module.cache.port
}

output "storage_bucket_names" {
  description = "Storage container names"
  value       = module.storage.bucket_names
}

output "storage_bucket_urls" {
  description = "Storage container URLs"
  value       = module.storage.bucket_urls
}

output "cdn_domain" {
  description = "CDN domain name"
  value       = var.enable_cdn ? module.cdn[0].domain_name : ""
}

output "dns_nameservers" {
  description = "DNS nameservers"
  value       = var.enable_dns ? module.dns[0].nameservers : []
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
