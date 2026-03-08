# ECS Fargate Test Execution Module
# Creates serverless test execution infrastructure

terraform {
  required_version = ">= 1.0"
}

# S3 bucket for test scripts and results
resource "aws_s3_bucket" "test_execution" {
  bucket = "${var.project_name}-test-execution-${var.environment}"

  tags = merge(var.tags, {
    Name    = "${var.project_name}-test-execution"
    Purpose = "Test execution scripts and results"
  })
}

resource "aws_s3_bucket_public_access_block" "test_execution" {
  bucket = aws_s3_bucket.test_execution.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "test_execution" {
  bucket = aws_s3_bucket.test_execution.id

  rule {
    id     = "cleanup-old-results"
    status = "Enabled"

    expiration {
      days = 30  # Delete test results after 30 days
    }

    filter {
      prefix = "test-results/"
    }
  }

  rule {
    id     = "cleanup-old-scripts"
    status = "Enabled"

    expiration {
      days = 7  # Delete test scripts after 7 days
    }

    filter {
      prefix = "test-scripts/"
    }
  }
}

# ECR repository for test runner image
resource "aws_ecr_repository" "test_runner" {
  name                 = "${var.project_name}-test-runner"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-test-runner"
    Purpose = "Playwright test runner container"
  })
}

resource "aws_ecr_lifecycle_policy" "test_runner" {
  repository = aws_ecr_repository.test_runner.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# CloudWatch log group for task logs
resource "aws_cloudwatch_log_group" "test_runner" {
  name              = "/ecs/${var.project_name}-test-runner"
  retention_in_days = 7  # Keep logs for 7 days

  tags = merge(var.tags, {
    Name    = "${var.project_name}-test-runner-logs"
    Purpose = "Test execution logs"
  })
}

# IAM role for task execution (used by ECS to pull images, write logs)
resource "aws_iam_role" "task_execution_role" {
  name = "${var.project_name}-test-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM role for task (used by the running container)
resource "aws_iam_role" "task_role" {
  name = "${var.project_name}-test-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Policy for task to access S3 bucket
resource "aws_iam_role_policy" "task_s3_access" {
  name = "s3-access"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.test_execution.arn,
          "${aws_s3_bucket.test_execution.arn}/*"
        ]
      }
    ]
  })
}

# Security group for Fargate tasks
resource "aws_security_group" "fargate_tasks" {
  name        = "${var.project_name}-fargate-tasks-${var.environment}"
  description = "Security group for ECS Fargate test execution tasks"
  vpc_id      = var.vpc_id

  # Allow outbound traffic to pull Docker images and access test targets
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-fargate-tasks"
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "test_execution" {
  name = "${var.project_name}-test-execution-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-test-execution"
    Purpose = "Test execution cluster"
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "test_runner" {
  family                   = "${var.project_name}-test-runner"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.default_cpu
  memory                   = var.default_memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([{
    name      = "test-runner"
    image     = "${aws_ecr_repository.test_runner.repository_url}:latest"
    essential = true

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.test_runner.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "test-runner"
      }
    }

    environment = [
      { name = "AWS_DEFAULT_REGION", value = var.region },
      { name = "S3_BUCKET", value = aws_s3_bucket.test_execution.id }
    ]

    # These will be overridden per task:
    # - BASE_URL
    # - CALLBACK_URL
    # - JOB_ID
    # - S3_SCRIPT_KEY
    # - S3_RESULTS_PREFIX
  }])

  tags = var.tags
}
