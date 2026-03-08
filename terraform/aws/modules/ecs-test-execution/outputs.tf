# Outputs for ECS Fargate Test Execution Module

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.test_execution.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.test_execution.arn
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.test_runner.arn
}

output "task_definition_family" {
  description = "Family name of the task definition"
  value       = aws_ecs_task_definition.test_runner.family
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for test execution"
  value       = aws_s3_bucket.test_execution.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for test execution"
  value       = aws_s3_bucket.test_execution.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for test runner image"
  value       = aws_ecr_repository.test_runner.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.test_runner.name
}

output "security_group_id" {
  description = "Security group ID for Fargate tasks"
  value       = aws_security_group.fargate_tasks.id
}

output "subnet_ids" {
  description = "Subnet IDs for Fargate tasks"
  value       = var.subnet_ids
}

output "task_execution_role_arn" {
  description = "ARN of the task execution IAM role"
  value       = aws_iam_role.task_execution_role.arn
}

output "task_role_arn" {
  description = "ARN of the task IAM role"
  value       = aws_iam_role.task_role.arn
}
