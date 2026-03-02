# Multi-Cloud Deployment System - Main Terraform Configuration
# Version: 1.0

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azure = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "local" {
    # Backend configuration passed via CLI
    # -backend-config="path=..."
  }
}

# Provider configuration
# Note: Both providers are configured but only resources for the selected cloud_provider are created
provider "aws" {
  region = var.region
  skip_region_validation = true
  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_requesting_account_id = true
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Local variables
locals {
  is_aws   = var.cloud_provider == "aws"
  is_azure = var.cloud_provider == "azure"

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "cloud-deploy"
      Terraform   = "true"
    }
  )
}

# Network module
module "network" {
  source = "./modules/network"

  environment    = var.environment
  cloud_provider = var.cloud_provider
  region         = var.region
  tags           = local.common_tags
}

# Compute module
module "compute" {
  source = "./modules/compute"

  environment     = var.environment
  cloud_provider  = var.cloud_provider
  region          = var.region
  instance_type   = var.instance_type
  instance_count  = var.instance_count
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.private_subnet_ids
  security_groups = [module.network.app_security_group_id]
  tags            = local.common_tags
}

# Database module
module "database" {
  source = "./modules/database"

  environment           = var.environment
  cloud_provider        = var.cloud_provider
  region                = var.region
  instance_class        = var.database_instance_class
  allocated_storage     = var.database_allocated_storage
  engine                = var.database_engine
  engine_version        = var.database_engine_version
  database_name         = var.database_name
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.private_subnet_ids
  security_group_ids    = [module.network.db_security_group_id]
  multi_az              = var.database_multi_az
  backup_retention_days = var.database_backup_retention_days
  storage_encrypted     = var.database_storage_encrypted
  tags                  = local.common_tags
}

# Cache module
module "cache" {
  source = "./modules/cache"

  environment          = var.environment
  cloud_provider       = var.cloud_provider
  region               = var.region
  node_type            = var.cache_node_type
  num_cache_nodes      = var.cache_num_nodes
  engine               = var.cache_engine
  engine_version       = var.cache_engine_version
  vpc_id               = module.network.vpc_id
  subnet_ids           = module.network.private_subnet_ids
  security_group_ids   = [module.network.cache_security_group_id]
  automatic_failover   = var.cache_automatic_failover
  tags                 = local.common_tags
}

# Storage module
module "storage" {
  source = "./modules/storage"

  environment    = var.environment
  cloud_provider = var.cloud_provider
  region         = var.region
  buckets        = var.storage_buckets
  versioning     = var.storage_versioning
  tags           = local.common_tags
}

# CDN module (optional)
module "cdn" {
  count = var.enable_cdn ? 1 : 0

  source = "./modules/cdn"

  environment    = var.environment
  cloud_provider = var.cloud_provider
  origin_domain  = var.cdn_origin_domain
  tags           = local.common_tags
}

# DNS module (optional)
module "dns" {
  count = var.enable_dns ? 1 : 0

  source = "./modules/dns"

  environment    = var.environment
  cloud_provider = var.cloud_provider
  zone_name      = var.dns_zone_name
  records        = var.dns_records
  tags           = local.common_tags
}
