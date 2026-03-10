variable "environment" { type = string }
variable "cloud_provider" { type = string }
variable "region" { type = string }
variable "instance_type" { type = string }
variable "instance_count" { type = number }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_groups" { type = list(string) }
variable "resource_group_name" {
  type    = string
  default = ""
}
variable "create_iam_instance_profile" {
  type        = bool
  default     = true
  description = "Create IAM instance profile for EC2 instances with SES permissions"
}
variable "tags" { type = map(string) }
