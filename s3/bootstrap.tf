terraform {
  backend "local" {
    path = "bootstrap.tfstate"  # Local state for initial creation
  }
}

# Fetch AWS account ID
data "aws_caller_identity" "current" {}

# Check if S3 bucket exists (safely)
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.tf_state_bucket
}

# Create S3 bucket only if it doesn't exist
resource "aws_s3_bucket" "terraform_state_bucket" {
  count = can(data.aws_s3_bucket.existing_bucket.id) ? 0 : 1

  bucket        = var.tf_state_bucket
  force_destroy = true  # Allow deletion even if not empty

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

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Check if DynamoDB table exists (safely)
data "aws_dynamodb_table" "existing_table" {
  name = "terraform-lock-table"
}

# Create DynamoDB table only if it doesn't exist
resource "aws_dynamodb_table" "terraform_state_lock" {
  count = can(data.aws_dynamodb_table.existing_table.id) ? 0 : 1

  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}