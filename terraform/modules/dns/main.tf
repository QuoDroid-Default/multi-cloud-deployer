# DNS Module - Placeholder

variable "environment" { type = string }
variable "cloud_provider" { type = string }
variable "zone_name" { type = string }
variable "records" {
  type    = list(any)
  default = []
}
variable "tags" { type = map(string) }

output "nameservers" {
  value = ["ns1.example.com", "ns2.example.com"]
}
