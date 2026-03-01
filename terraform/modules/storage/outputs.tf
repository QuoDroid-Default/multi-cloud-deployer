output "bucket_names" {
  value = var.cloud_provider == "aws" ? [for b in aws_s3_bucket.main : b.id] : [for c in azurerm_storage_container.main : c.name]
}

output "bucket_urls" {
  value = var.cloud_provider == "aws" ? [for b in aws_s3_bucket.main : "s3://${b.id}"] : []
}
