variable "environment" { type = string }
variable "cloud_provider" { type = string }
variable "region" { type = string }
variable "buckets" { type = list(string) }
variable "versioning" { type = bool }
variable "resource_group_name" {
  type    = string
  default = ""
}
variable "tags" { type = map(string) }
