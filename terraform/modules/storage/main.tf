# Storage Module

locals {
  is_aws = var.cloud_provider == "aws"
}

resource "aws_s3_bucket" "main" {
  for_each = local.is_aws ? toset(var.buckets) : []

  bucket = "${var.environment}-${each.key}"
  tags   = merge(var.tags, { Purpose = each.key })
}

resource "aws_s3_bucket_versioning" "main" {
  for_each = local.is_aws && var.versioning ? toset(var.buckets) : []

  bucket = aws_s3_bucket.main[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "azurerm_storage_account" "main" {
  count = local.is_aws ? 0 : 1

  name                     = "${replace(var.environment, "-", "")}storage"
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_storage_container" "main" {
  for_each = local.is_aws ? [] : toset(var.buckets)

  name                  = each.key
  storage_account_name  = azurerm_storage_account.main[0].name
  container_access_type = "private"
}
