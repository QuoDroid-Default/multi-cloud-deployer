# AWS Infrastructure Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.app[*].id
}

output "instance_ips" {
  description = "EC2 instance private IPs"
  value       = aws_instance.app[*].private_ip
}

output "instance_public_ips" {
  description = "EC2 instance public IPs"
  value       = aws_instance.app[*].public_ip
}

output "ssh_private_key" {
  description = "SSH private key for instance access"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

output "database_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "database_port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "database_password" {
  description = "Database password"
  value       = random_password.db.result
  sensitive   = true
}

output "cache_endpoint" {
  description = "ElastiCache endpoint"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "cache_port" {
  description = "Cache port"
  value       = aws_elasticache_cluster.main.cache_nodes[0].port
}

output "storage_bucket_names" {
  description = "S3 bucket names"
  value       = [for b in aws_s3_bucket.main : b.id]
}

output "storage_bucket_urls" {
  description = "S3 bucket URLs"
  value       = [for b in aws_s3_bucket.main : "s3://${b.id}"]
}

output "cdn_domain" {
  description = "CloudFront domain name"
  value       = var.enable_cdn && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].domain_name : ""
}

output "dns_nameservers" {
  description = "Route53 nameservers"
  value       = var.enable_dns && length(aws_route53_zone.main) > 0 ? aws_route53_zone.main[0].name_servers : []
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
