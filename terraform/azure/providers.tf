# Azure Provider Configuration
# This directory is used exclusively for Azure deployments

terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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
