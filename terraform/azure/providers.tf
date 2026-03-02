# Azure Provider Configuration
# This directory contains ONLY Azure resources - no AWS provider needed

terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "local" {
    # Backend configuration passed via CLI
    # -backend-config="path=..."
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
