# AWS Provider Configuration
# This directory contains ONLY AWS resources - no Azure provider needed

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

provider "aws" {
  region = var.region
}
