# Fetch the current AWS account ID
data "aws_caller_identity" "current" {}

# Check if the S3 bucket already exists
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.tf_state_bucket
}

# Create S3 bucket for Terraform state if it doesn't already exist
resource "aws_s3_bucket" "terraform_state_bucket" {
  count = data.aws_s3_bucket.existing_bucket.id == "" ? 1 : 0

  bucket = var.tf_state_bucket
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


# Check if the DynamoDB table already exists
data "aws_dynamodb_table" "existing_table" {
  name = "terraform-lock-table"
}

# Create DynamoDB table for state locking if it doesn't already exist
resource "aws_dynamodb_table" "terraform_state_lock" {
  count = data.aws_dynamodb_table.existing_table.id == "" ? 1 : 0

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

  