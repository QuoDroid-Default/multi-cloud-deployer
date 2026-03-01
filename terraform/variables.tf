# Multi-Cloud Deployment System - Variables

variable "environment" {
  description = "Environment name (prod, demo, test, etc.)"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider (aws or azure)"
  type        = string
  validation {
    condition     = contains(["aws", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be 'aws' or 'azure'."
  }
}

variable "region" {
  description = "Cloud region"
  type        = string
}

# Compute variables
variable "instance_type" {
  description = "Instance type (from size preset)"
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
  default     = "15.4"
}

variable "database_instance_class" {
  description = "Database instance class (from size preset)"
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
  description = "Enable multi-AZ for database"
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
  default     = "7.0"
}

variable "cache_node_type" {
  description = "Cache node type (from size preset)"
  type        = string
}

variable "cache_num_nodes" {
  description = "Number of cache nodes"
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
  description = "Storage buckets to create"
  type        = list(string)
  default     = ["artifacts", "static"]
}

variable "storage_versioning" {
  description = "Enable storage versioning"
  type        = bool
  default     = false
}

# CDN variables
variable "enable_cdn" {
  description = "Enable CDN"
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
  description = "Enable DNS management"
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
