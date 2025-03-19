terraform {
  backend "s3" {
    bucket = "akash-terraform-state-bucket"  # Your S3 bucket name
    key    = "infra/terraform.tfstate"      # Path to infra's state file
    region = "us-east-1"                    # AWS region
    encrypt = true                          # Encrypt the state file at rest
  }
}

provider "aws" {
  region = var.aws_region
}

# Fetch existing IAM role
data "aws_iam_role" "existing_terraform_execution_role" {
  count = var.create_role ? 0 : 1  # Fetch the role only if `var.create_role` is false
  name  = "TerraformCIExecutionRole"
}

# Create IAM Execution Role for Terraform CI/CD if it doesn't exist
resource "aws_iam_role" "terraform_execution_role" {
  count = var.create_role ? 1 : 0  # Create the role only if `var.create_role` is true

  name               = "TerraformCIExecutionRole"
  description        = "Role for basic Terraform CI/CD executions"
  max_session_duration = 3600 # 1 hour maximum

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"  # Allow the root user to assume this role
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}

# Fetch existing IAM policy
data "aws_iam_policy" "existing_terraform_state_access" {
  count = var.create_policy ? 0 : 1  # Fetch the policy only if `var.create_policy` is false
  name  = "TerraformStateAccess"
}

# Create IAM Policy if it doesn't exist
resource "aws_iam_policy" "terraform_state_access" {
  count = var.create_policy ? 1 : 0  # Create the policy only if `var.create_policy` is true

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

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "state_access" {
  count = length(aws_iam_role.terraform_execution_role) > 0 ? 1 : 0

  role       = aws_iam_role.terraform_execution_role[0].name
  policy_arn = var.create_policy ? aws_iam_policy.terraform_state_access[0].arn : data.aws_iam_policy.existing_terraform_state_access[0].arn
}

# Fetch the current AWS account ID
data "aws_caller_identity" "current" {}