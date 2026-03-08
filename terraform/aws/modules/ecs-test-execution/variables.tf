# Variables for ECS Fargate Test Execution Module

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (test/demo/prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Fargate tasks"
  type        = list(string)
}

variable "default_cpu" {
  description = "Default CPU units for Fargate tasks (1024 = 1 vCPU)"
  type        = string
  default     = "1024"
}

variable "default_memory" {
  description = "Default memory for Fargate tasks in MB"
  type        = string
  default     = "2048"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
