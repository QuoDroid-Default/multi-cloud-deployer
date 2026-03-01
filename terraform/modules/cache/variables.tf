variable "environment" { type = string }
variable "cloud_provider" { type = string }
variable "region" { type = string }
variable "node_type" { type = string }
variable "num_cache_nodes" { type = number }
variable "engine" { type = string }
variable "engine_version" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "automatic_failover" { type = bool }
variable "resource_group_name" { type = string; default = "" }
variable "tags" { type = map(string) }
