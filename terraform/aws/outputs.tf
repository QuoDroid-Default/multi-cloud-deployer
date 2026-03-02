# AWS Infrastructure Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = module.compute.instance_ids
}

output "instance_ips" {
  description = "EC2 instance private IPs"
  value       = module.compute.instance_private_ips
}

output "instance_public_ips" {
  description = "EC2 instance public IPs"
  value       = module.compute.instance_public_ips
}

output "database_endpoint" {
  description = "RDS endpoint"
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
  description = "ElastiCache endpoint"
  value       = module.cache.endpoint
}

output "cache_port" {
  description = "Cache port"
  value       = module.cache.port
}

output "storage_bucket_names" {
  description = "S3 bucket names"
  value       = module.storage.bucket_names
}

output "storage_bucket_urls" {
  description = "S3 bucket URLs"
  value       = module.storage.bucket_urls
}

output "cdn_domain" {
  description = "CloudFront domain name"
  value       = var.enable_cdn ? module.cdn[0].domain_name : ""
}

output "dns_nameservers" {
  description = "Route53 nameservers"
  value       = var.enable_dns ? module.dns[0].nameservers : []
}

output "deployment_summary" {
  description = "Deployment summary"
  value = {
    environment    = var.environment
    cloud_provider = "aws"
    region         = var.region
    instance_count = var.instance_count
    instance_type  = var.instance_type
  }
}
