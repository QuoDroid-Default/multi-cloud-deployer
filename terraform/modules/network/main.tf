# Network Module - Multi-Cloud VPC/VNet

locals {
  is_aws   = var.cloud_provider == "aws"
  is_azure = var.cloud_provider == "azure"
}

# AWS VPC
resource "aws_vpc" "main" {
  count = local.is_aws ? 1 : 0

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.environment}-vpc"
  })
}

resource "aws_subnet" "public" {
  count = local.is_aws ? 2 : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available[0].names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.environment}-public-${count.index + 1}"
  })
}

resource "aws_subnet" "private" {
  count = local.is_aws ? 2 : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available[0].names[count.index]

  tags = merge(var.tags, {
    Name = "${var.environment}-private-${count.index + 1}"
  })
}

resource "aws_internet_gateway" "main" {
  count = local.is_aws ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(var.tags, {
    Name = "${var.environment}-igw"
  })
}

resource "aws_route_table" "public" {
  count = local.is_aws ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = local.is_aws ? 2 : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Security Groups
resource "aws_security_group" "app" {
  count = local.is_aws ? 1 : 0

  name_prefix = "${var.environment}-app-"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-app-sg"
  })
}

resource "aws_security_group" "db" {
  count = local.is_aws ? 1 : 0

  name_prefix = "${var.environment}-db-"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app[0].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-db-sg"
  })
}

resource "aws_security_group" "cache" {
  count = local.is_aws ? 1 : 0

  name_prefix = "${var.environment}-cache-"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app[0].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-cache-sg"
  })
}

# Data sources
data "aws_availability_zones" "available" {
  count = local.is_aws ? 1 : 0
  state = "available"
}

# Azure VNet (placeholder)
resource "azurerm_resource_group" "main" {
  count = local.is_azure ? 1 : 0

  name     = "${var.environment}-rg"
  location = var.region
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  count = local.is_azure ? 1 : 0

  name                = "${var.environment}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  tags                = var.tags
}

resource "azurerm_subnet" "public" {
  count = local.is_azure ? 1 : 0

  name                 = "${var.environment}-public-subnet"
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private" {
  count = local.is_azure ? 1 : 0

  name                 = "${var.environment}-private-subnet"
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.10.0/24"]
}
