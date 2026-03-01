output "instance_ids" {
  value = var.cloud_provider == "aws" ? aws_instance.app[*].id : azurerm_linux_virtual_machine.app[*].id
}

output "instance_private_ips" {
  value = var.cloud_provider == "aws" ? aws_instance.app[*].private_ip : azurerm_linux_virtual_machine.app[*].private_ip_address
}

output "instance_public_ips" {
  value = var.cloud_provider == "aws" ? aws_instance.app[*].public_ip : []
}
