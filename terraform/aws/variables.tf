# AWS Infrastructure Variables

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "coco-testai"
}

variable "environment" {
  description = "Environment name (prod, demo, test, etc.)"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider (always 'aws' for this configuration)"
  type        = string
  default     = "aws"
  validation {
    condition     = var.cloud_provider == "aws"
    error_message = "This configuration only supports AWS. Use terraform/azure/ for Azure deployments."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
}

# Compute variables
variable "instance_type" {
  description = "EC2 instance type (from size preset)"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH (0.0.0.0/0 for CI/CD compatibility)"
  type        = list(string)
  default = [
    "0.0.0.0/0"  # Allow from anywhere - protected by SSH key authentication
  ]
  # Note: For production environments, restrict this to specific IPs
  # GitHub Actions IPs can be fetched from: https://api.github.com/meta
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB (AWS Free Tier includes 30GB)"
  type        = number
  default     = 30
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
  description = "RDS instance class (from size preset)"
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
  description = "ElastiCache node type (from size preset)"
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
  description = "S3 buckets to create"
  type        = list(string)
  default     = ["artifacts", "static"]
}

variable "storage_versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = false
}

# CDN variables
variable "enable_cdn" {
  description = "Enable CloudFront CDN"
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
  description = "Enable Route53 DNS management"
  type        = bool
  default     = false
}

variable "dns_zone_name" {
  description = "Route53 zone name"
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

# Test Execution Variables
variable "enable_test_execution" {
  description = "Enable ECS Fargate test execution infrastructure"
  type        = bool
  default     = false
}

variable "test_execution_cpu" {
  description = "Default CPU units for test execution tasks (1024 = 1 vCPU)"
  type        = string
  default     = "1024"
}

variable "test_execution_memory" {
  description = "Default memory for test execution tasks in MB"
  type        = string
  default     = "2048"
}
