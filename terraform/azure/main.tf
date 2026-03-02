# Azure Infrastructure Configuration - Complete
# All resources defined inline (no shared modules)

locals {
  common_tags = merge(
    var.tags,
    {
      Environment    = var.environment
      ManagedBy      = "cloud-deploy"
      Terraform      = "true"
      CloudProvider  = "azure"
    }
  )

  location = var.region
}

################################################################################
# RESOURCE GROUP
################################################################################

resource "azurerm_resource_group" "main" {
  name     = "${var.environment}-rg"
  location = local.location
  tags     = local.common_tags
}

################################################################################
# NETWORK
################################################################################

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.environment}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]

  tags = local.common_tags
}

# Public Subnets
resource "azurerm_subnet" "public" {
  count = 2

  name                 = "${var.environment}-public-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
}

# Private Subnets
resource "azurerm_subnet" "private" {
  count = 2

  name                 = "${var.environment}-private-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.${count.index + 10}.0/24"]
}

# Network Security Group for App
resource "azurerm_network_security_group" "app" {
  name                = "${var.environment}-app-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

# Network Security Group for Database
resource "azurerm_network_security_group" "db" {
  name                = "${var.environment}-db-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-postgres"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

################################################################################
# COMPUTE
################################################################################

# Network Interfaces
resource "azurerm_network_interface" "app" {
  count = var.instance_count

  name                = "${var.environment}-app-nic-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private[count.index % 2].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}

# Associate NSG with NICs
resource "azurerm_network_interface_security_group_association" "app" {
  count = var.instance_count

  network_interface_id      = azurerm_network_interface.app[count.index].id
  network_security_group_id = azurerm_network_security_group.app.id
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "app" {
  count = var.instance_count

  name                = "${var.environment}-app-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.instance_type
  admin_username      = "azureuser"

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDummy"
  }

  network_interface_ids = [
    azurerm_network_interface.app[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}

################################################################################
# DATABASE
################################################################################

# Random password for DB
resource "random_password" "db" {
  length  = 16
  special = true
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                = "${var.environment}-db"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name   = var.database_instance_class
  version    = var.database_engine_version
  storage_mb = var.database_allocated_storage * 1024

  administrator_login    = "dbadmin"
  administrator_password = random_password.db.result

  zone                      = var.database_multi_az ? null : "1"
  backup_retention_days     = var.database_backup_retention_days
  geo_redundant_backup_enabled = var.database_multi_az

  tags = local.common_tags
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

################################################################################
# CACHE
################################################################################

# Redis Cache
resource "azurerm_redis_cache" "main" {
  name                = "${var.environment}-cache"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }

  tags = local.common_tags
}

################################################################################
# STORAGE
################################################################################

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${replace(var.environment, "-", "")}storage${substr(md5(azurerm_resource_group.main.id), 0, 8)}"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

# Storage Containers
resource "azurerm_storage_container" "main" {
  for_each = toset(var.storage_buckets)

  name                  = each.key
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Blob versioning (if enabled)
resource "azurerm_storage_management_policy" "versioning" {
  count = var.storage_versioning ? 1 : 0

  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "versioning-policy"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      version {
        delete_after_days_since_creation = 90
      }
    }
  }
}

################################################################################
# CDN (Optional)
################################################################################

resource "azurerm_cdn_profile" "main" {
  count = var.enable_cdn ? 1 : 0

  name                = "${var.environment}-cdn-profile"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard_Microsoft"

  tags = local.common_tags
}

resource "azurerm_cdn_endpoint" "main" {
  count = var.enable_cdn ? 1 : 0

  name                = "${var.environment}-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.main[0].name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  origin {
    name      = "primary"
    host_name = var.cdn_origin_domain
  }

  tags = local.common_tags
}

################################################################################
# DNS (Optional)
################################################################################

resource "azurerm_dns_zone" "main" {
  count = var.enable_dns ? 1 : 0

  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

resource "azurerm_dns_a_record" "custom" {
  for_each = var.enable_dns ? { for r in var.dns_records : r.name => r if r.type == "A" } : {}

  name                = each.value.name
  zone_name           = azurerm_dns_zone.main[0].name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [each.value.value]
}
