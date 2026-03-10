# AWS Infrastructure Configuration - Complete
# All resources defined inline (no shared modules)

locals {
  common_tags = merge(
    var.tags,
    {
      Environment      = var.environment
      ManagedBy        = "cloud-deploy"
      DeploymentTool   = "multi-cloud-deployer"
      AutoManaged      = "true"
      Terraform        = "true"
      CloudProvider    = "aws"
    }
  )
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# NETWORK
################################################################################

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.environment}-vpc"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.environment}-public-${count.index + 1}"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${var.environment}-private-${count.index + 1}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.environment}-igw"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-public-rt"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.main.id

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
    cidr_blocks = var.ssh_allowed_cidrs
    description = "SSH from GitHub Actions only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-app-sg"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-db-sg"
  })
}

resource "aws_security_group" "cache" {
  name        = "${var.environment}-cache-sg"
  description = "Security group for ElastiCache cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-cache-sg"
  })
}

################################################################################
# COMPUTE
################################################################################

# AMI Data Source
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# SSH Key Pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_id" "key_suffix" {
  byte_length = 4
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.environment}-deployer-key-${random_id.key_suffix.hex}"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = local.common_tags
}

################################################################################
# IAM ROLE FOR EC2 (SES PERMISSIONS)
################################################################################

# IAM role for EC2 instances
resource "aws_iam_role" "ec2_app_role" {
  name = "${var.environment}-ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.environment}-ec2-app-role"
  })
}

# SES send email policy
resource "aws_iam_role_policy" "ses_send_email" {
  name = "${var.environment}-ses-send-email"
  role = aws_iam_role.ec2_app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_app_profile" {
  name = "${var.environment}-ec2-app-profile"
  role = aws_iam_role.ec2_app_role.name

  tags = merge(local.common_tags, {
    Name = "${var.environment}-ec2-app-profile"
  })
}

# EC2 Instances
resource "aws_instance" "app" {
  count = var.instance_count

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index % 2].id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_app_profile.name

  tags = merge(local.common_tags, {
    Name = "${var.environment}-app-${count.index + 1}"
  })
}

# Elastic IPs for EC2 Instances
# Ensures instances keep same IP after stop/start
resource "aws_eip" "app" {
  count  = var.instance_count
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.environment}-app-eip-${count.index + 1}"
  })
}

# Associate Elastic IPs with EC2 Instances
resource "aws_eip_association" "app" {
  count         = var.instance_count
  instance_id   = aws_instance.app[count.index].id
  allocation_id = aws_eip.app[count.index].id
}

################################################################################
# DATABASE
################################################################################

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(local.common_tags, {
    Name = "${var.environment}-db-subnet-group"
  })
}

# Random password for DB
# RDS password constraints: no '/', '@', '"', or spaces
resource "random_password" "db" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}|;:,.<>?"
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.environment}-db"

  engine         = var.database_engine
  engine_version = var.database_engine_version
  instance_class = var.database_instance_class

  allocated_storage = var.database_allocated_storage
  storage_encrypted = var.database_storage_encrypted
  storage_type      = "gp3"

  db_name  = var.database_name
  username = "dbadmin"
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az               = var.database_multi_az
  backup_retention_period = var.database_backup_retention_days
  skip_final_snapshot    = true

  lifecycle {
    # Prevent unnecessary recreation on minor version updates
    ignore_changes = [
      engine_version,  # Allow minor version auto-upgrades
    ]
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-db"
  })
}

################################################################################
# CACHE
################################################################################

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.environment}-cache-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = local.common_tags
}

# ElastiCache Cluster
resource "aws_elasticache_cluster" "main" {
  cluster_id = "${var.environment}-cache"

  engine               = var.cache_engine
  engine_version       = var.cache_engine_version
  node_type            = var.cache_node_type
  num_cache_nodes      = var.cache_num_nodes
  parameter_group_name = var.cache_engine == "redis" ? "default.redis7" : "default.memcached1.6"

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.cache.id]

  lifecycle {
    # Prevent unnecessary recreation on minor version updates
    ignore_changes = [
      engine_version,  # Allow minor version auto-upgrades
    ]
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-cache"
  })
}

################################################################################
# STORAGE
################################################################################

# Random suffix for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Buckets
resource "aws_s3_bucket" "main" {
  for_each = toset(var.storage_buckets)

  bucket = "${var.environment}-${each.key}-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${each.key}"
  })
}

# S3 Versioning
resource "aws_s3_bucket_versioning" "main" {
  for_each = toset(var.storage_buckets)

  bucket = aws_s3_bucket.main[each.key].id

  versioning_configuration {
    status = var.storage_versioning ? "Enabled" : "Suspended"
  }
}

# S3 Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  for_each = toset(var.storage_buckets)

  bucket = aws_s3_bucket.main[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Account ID data source
data "aws_caller_identity" "current" {}

################################################################################
# CDN (Optional)
################################################################################

resource "aws_cloudfront_distribution" "main" {
  count = var.enable_cdn ? 1 : 0

  enabled             = true
  wait_for_deployment = false  # Don't block on deployment - speeds up creation and destruction
  retain_on_delete    = false  # Ensure distribution is fully deleted, not just removed from state
  comment             = "${var.environment} CDN"

  # 2026 Best Practice: Enable compression for better performance
  is_ipv6_enabled = true
  http_version    = "http2and3"

  origin {
    # 2026 Best Practice: CloudFront requires DNS hostname, not IP address
    # Use Elastic IP DNS to ensure CloudFront works after EC2 stop/start
    # Elastic IP DNS format: ec2-X-X-X-X.REGION.compute.amazonaws.com
    domain_name = var.cdn_origin_domain != "" ? var.cdn_origin_domain : "ec2-${replace(aws_eip.app[0].public_ip, ".", "-")}.${var.region}.compute.amazonaws.com"
    origin_id   = "primary"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      # 2026 Best Practice: Use http-only for EC2 origins (HTTPS terminates at CloudFront)
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Ensure Elastic IP is associated before CloudFront references it
  depends_on = [aws_eip_association.app]

  default_cache_behavior {
    target_origin_id       = "primary"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true  # 2026 Best Practice: Enable gzip/brotli compression

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
      cookies {
        forward = "all"  # Forward cookies for Django sessions
      }
    }

    min_ttl     = 0
    default_ttl = 0      # 2026 Best Practice: Cache only when origin sends Cache-Control
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"  # 2026 Best Practice: Modern TLS only
  }

  tags = local.common_tags
}

################################################################################
# DNS (Optional)
################################################################################

resource "aws_route53_zone" "main" {
  count = var.enable_dns ? 1 : 0

  name = var.dns_zone_name

  tags = local.common_tags
}

resource "aws_route53_record" "custom" {
  for_each = var.enable_dns ? { for r in var.dns_records : r.name => r } : {}

  zone_id = aws_route53_zone.main[0].zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]
}

################################################################################
# TEST EXECUTION (ECS Fargate for Production)
################################################################################

module "ecs_test_execution" {
  count  = var.enable_test_execution ? 1 : 0
  source = "./modules/ecs-test-execution"

  project_name = var.project_name
  environment  = var.environment
  region       = var.region
  vpc_id       = aws_vpc.main.id
  subnet_ids   = aws_subnet.public[*].id

  default_cpu    = var.test_execution_cpu
  default_memory = var.test_execution_memory

  tags = local.common_tags
}
