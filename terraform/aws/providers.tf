# AWS Provider Configuration
# This directory is used exclusively for AWS deployments

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
