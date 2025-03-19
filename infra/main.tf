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

# Check if the IAM role already exists
data "aws_iam_role" "existing_terraform_execution_role" {
  count = var.create_iam_role ? 1 : 0
  name  = "TerraformCIExecutionRole"
}

# Create IAM Role for Terraform CI/CD (only if it doesn't exist)
resource "aws_iam_role" "terraform_execution_role" {
  count = var.create_iam_role && length(data.aws_iam_role.existing_terraform_execution_role) == 0 ? 1 : 0

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

# Check if the IAM policy already exists
data "aws_iam_policy" "existing_terraform_state_access" {
  count = var.create_iam_policy ? 1 : 0
  name  = "TerraformStateAccess"
}

# Create IAM Policy for Terraform state access (only if it doesn't exist)
resource "aws_iam_policy" "terraform_state_access" {
  count = var.create_iam_policy && length(data.aws_iam_policy.existing_terraform_state_access) == 0 ? 1 : 0

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

# Attach the policy to the IAM role (only if both the role and policy are created)
resource "aws_iam_role_policy_attachment" "state_access" {
  count = length(aws_iam_role.terraform_execution_role) > 0 && length(aws_iam_policy.terraform_state_access) > 0 ? 1 : 0

  role       = aws_iam_role.terraform_execution_role[0].name
  policy_arn = aws_iam_policy.terraform_state_access[0].arn
}

# Outputs
output "iam_role_created" {
  description = "Whether the IAM role was created."
  value       = length(aws_iam_role.terraform_execution_role) > 0
}

output "iam_role_name" {
  description = "The name of the IAM role."
  value       = length(aws_iam_role.terraform_execution_role) > 0 ? aws_iam_role.terraform_execution_role[0].name : data.aws_iam_role.existing_terraform_execution_role[0].name
}

output "iam_policy_created" {
  description = "Whether the IAM policy was created."
  value       = length(aws_iam_policy.terraform_state_access) > 0
}

output "iam_policy_name" {
  description = "The name of the IAM policy."
  value       = length(aws_iam_policy.terraform_state_access) > 0 ? aws_iam_policy.terraform_state_access[0].name : data.aws_iam_policy.existing_terraform_state_access[0].name
}