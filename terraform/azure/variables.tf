# Azure Infrastructure Variables

variable "environment" {
  description = "Environment name (prod, demo, test, etc.)"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider (always 'azure' for this configuration)"
  type        = string
  default     = "azure"
  validation {
    condition     = var.cloud_provider == "azure"
    error_message = "This configuration only supports Azure. Use terraform/aws/ for AWS deployments."
  }
}

variable "region" {
  description = "Azure region"
  type        = string
}

# Compute variables
variable "instance_type" {
  description = "VM size (from size preset)"
  type        = string
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

# Database variables
variable "database_engine" {
  description = "Database engine (postgres, mysql, mariadb)"
  type        = string
  default     = "postgres"
}

variable "database_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15"
}

variable "database_instance_class" {
  description = "Database SKU (from size preset)"
  type        = string
}

variable "database_allocated_storage" {
  description = "Database allocated storage in GB"
  type        = number
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "app_db"
}

variable "database_multi_az" {
  description = "Enable zone redundancy for database"
  type        = bool
  default     = false
}

variable "database_backup_retention_days" {
  description = "Database backup retention in days"
  type        = number
  default     = 7
}

variable "database_storage_encrypted" {
  description = "Enable database storage encryption"
  type        = bool
  default     = false
}

# Cache variables
variable "cache_engine" {
  description = "Cache engine (redis or memcached)"
  type        = string
  default     = "redis"
}

variable "cache_engine_version" {
  description = "Cache engine version"
  type        = string
  default     = "6.0"
}

variable "cache_node_type" {
  description = "Redis cache SKU (from size preset)"
  type        = string
}

variable "cache_num_nodes" {
  description = "Number of cache shards"
  type        = number
  default     = 1
}

variable "cache_automatic_failover" {
  description = "Enable automatic failover for cache"
  type        = bool
  default     = false
}

# Storage variables
variable "storage_buckets" {
  description = "Storage containers to create"
  type        = list(string)
  default     = ["artifacts", "static"]
}

variable "storage_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = false
}

# CDN variables
variable "enable_cdn" {
  description = "Enable Azure CDN"
  type        = bool
  default     = false
}

variable "cdn_origin_domain" {
  description = "CDN origin domain"
  type        = string
  default     = ""
}

# DNS variables
variable "enable_dns" {
  description = "Enable Azure DNS management"
  type        = bool
  default     = false
}

variable "dns_zone_name" {
  description = "DNS zone name"
  type        = string
  default     = ""
}

variable "dns_records" {
  description = "DNS records to create"
  type        = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
}

# Domain variables
variable "webapp_domain" {
  description = "Web app domain"
  type        = string
  default     = ""
}

variable "api_domain" {
  description = "API domain"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
