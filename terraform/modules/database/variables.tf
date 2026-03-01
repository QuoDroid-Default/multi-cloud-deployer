variable "environment" { type = string }
variable "cloud_provider" { type = string }
variable "region" { type = string }
variable "instance_class" { type = string }
variable "allocated_storage" { type = number }
variable "engine" { type = string }
variable "engine_version" { type = string }
variable "database_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "multi_az" { type = bool }
variable "backup_retention_days" { type = number }
variable "storage_encrypted" { type = bool }
variable "resource_group_name" { type = string; default = "" }
variable "tags" { type = map(string) }
