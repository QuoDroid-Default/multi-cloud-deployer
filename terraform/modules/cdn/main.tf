# CDN Module - Placeholder

variable "environment" { type = string }
variable "cloud_provider" { type = string }
variable "origin_domain" { type = string }
variable "tags" { type = map(string) }

output "domain_name" {
  value = "cdn.example.com"
}
