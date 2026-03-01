# Compute Module

locals {
  is_aws = var.cloud_provider == "aws"
}

resource "aws_instance" "app" {
  count = local.is_aws ? var.instance_count : 0

  ami           = data.aws_ami.ubuntu[0].id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_groups

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-app-${count.index + 1}"
  })
}

data "aws_ami" "ubuntu" {
  count = local.is_aws ? 1 : 0

  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  count = local.is_aws ? 0 : var.instance_count

  name                = "${var.environment}-app-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.region
  size                = var.instance_type
  admin_username      = "ubuntu"

  network_interface_ids = [azurerm_network_interface.app[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = var.tags
}

resource "azurerm_network_interface" "app" {
  count = local.is_aws ? 0 : var.instance_count

  name                = "${var.environment}-app-nic-${count.index + 1}"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[0]
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}
