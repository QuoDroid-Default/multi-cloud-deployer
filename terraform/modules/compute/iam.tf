# IAM Role and Instance Profile for EC2 instances to access AWS services

locals {
  create_iam = local.is_aws && var.create_iam_instance_profile
}

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  count = local.create_iam ? 1 : 0

  name = "${var.environment}-ec2-role"

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

  tags = merge(var.tags, {
    Name = "${var.environment}-ec2-role"
  })
}

# IAM Policy for SES email sending
resource "aws_iam_role_policy" "ses_policy" {
  count = local.create_iam ? 1 : 0

  name = "${var.environment}-ses-policy"
  role = aws_iam_role.ec2_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SESEmailPermissions"
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail",
          "ses:GetSendQuota",
          "ses:GetSendStatistics"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  count = local.create_iam ? 1 : 0

  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role[0].name

  tags = merge(var.tags, {
    Name = "${var.environment}-ec2-profile"
  })
}
