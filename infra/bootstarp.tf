# Configure the S3 backend for Terraform state
terraform {
  backend "s3" {
    bucket         = "akash-terraform-state-bucket" # The bucket must already exist
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table" # Use DynamoDB for state locking
  }
}

# Fetch existing S3 bucket for Terraform state
data "aws_s3_bucket" "existing_state_bucket" {
  bucket = "akash-terraform-state-bucket"
}

# Fetch existing DynamoDB table for Terraform state locking
data "aws_dynamodb_table" "existing_terraform_state_lock" {
  name = "terraform-lock-table"
}

# Declare the random_id resource to generate a suffix (if needed for naming)
resource "random_id" "build_suffix" {
  byte_length = 8
}

# Create DynamoDB table for state locking if not already present
resource "aws_dynamodb_table" "terraform_state_lock" {
  count = length(data.aws_dynamodb_table.existing_terraform_state_lock.*.id) == 0 ? 1 : 0

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

  lifecycle {
    prevent_destroy = true
  }
}

# Create S3 bucket for Terraform state if not already present
resource "aws_s3_bucket" "terraform_state_bucket" {
  count = length(data.aws_s3_bucket.existing_state_bucket.*.id) == 0 ? 1 : 0

  bucket = "akash-terraform-state-bucket"
  acl    = "private"

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

  lifecycle {
    prevent_destroy = true
  }
}