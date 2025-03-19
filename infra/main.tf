provider "aws" {
  region = var.aws_region
}

# Fetch the current AWS account ID
data "aws_caller_identity" "current" {}

# Check if the S3 bucket already exists
data "aws_s3_bucket" "existing_state_bucket" {
  bucket = "akash-terraform-state-bucket"
}

# Check if the DynamoDB table already exists
data "aws_dynamodb_table" "existing_terraform_state_lock" {
  name = "terraform-lock-table"
}

# Create S3 bucket for Terraform state (only if it doesn't exist)
resource "aws_s3_bucket" "state" {
  count = length(data.aws_s3_bucket.existing_state_bucket) == 0 ? 1 : 0

  bucket = "akash-terraform-state-bucket"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  depends_on = [aws_dynamodb_table.terraform_state_lock]
}

# Create DynamoDB table for Terraform state locking (only if it doesn't exist)
resource "aws_dynamodb_table" "terraform_state_lock" {
  count = length(data.aws_dynamodb_table.existing_terraform_state_lock) == 0 ? 1 : 0

  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Terraform Backend Configuration (only after the S3 bucket and DynamoDB table are created)
terraform {
  backend "s3" {
    bucket = "akash-terraform-state-bucket"
    key    = "path/to/terraform.tfstate"
    region = var.aws_region
    encrypt = true
    dynamodb_table = "terraform-lock-table"
    acl    = "private"
  }
}

# IAM Role and Policy Configuration (existing)
resource "aws_iam_role" "terraform_execution_role" {
  count = length(data.aws_iam_role.existing_terraform_execution_role) == 0 ? 1 : 0

  name               = "TerraformCIExecutionRole"
  description        = "Role for basic Terraform CI/CD executions"
  max_session_duration = 3600 # 1 hour maximum

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_policy" "terraform_state_access" {
  count = length(data.aws_iam_policy.existing_terraform_state_access) == 0 ? 1 : 0

  name        = "TerraformStateAccess"
  description = "Minimum permissions for S3 state management"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.tf_state_bucket}",
          "arn:aws:s3:::${var.tf_state_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "state_access" {
  count = length(aws_iam_role.terraform_execution_role) > 0 && length(aws_iam_policy.terraform_state_access) > 0 ? 1 : 0

  role       = aws_iam_role.terraform_execution_role[0].name
  policy_arn = aws_iam_policy.terraform_state_access[0].arn
}
