terraform {
  backend "s3" {
    bucket         = "akash-terraform-state-bucket" # The bucket must already exist
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}

# Fetch existing S3 bucket for Terraform state (use existing bucket)
data "aws_s3_bucket" "existing_state_bucket" {
  bucket = "akash-terraform-state-bucket"
}

# DynamoDB table for Terraform state locking
data "aws_dynamodb_table" "existing_terraform_state_lock" {
  name = "terraform-lock-table"
}

# Create DynamoDB table for state locking (if it doesn't exist)
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

# Declare the random_id resource to generate a suffix (remove if not used)
resource "random_id" "build_suffix" {
  byte_length = 8
}

# Enable versioning for the S3 bucket (only if needed)
resource "aws_s3_bucket_versioning" "state" {
  count = length(data.aws_s3_bucket.existing_state_bucket) > 0 ? 1 : 0

  bucket = data.aws_s3_bucket.existing_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure public access block for the S3 bucket (only if needed)
resource "aws_s3_bucket_public_access_block" "state" {
  count = length(data.aws_s3_bucket.existing_state_bucket) > 0 ? 1 : 0

  bucket = data.aws_s3_bucket.existing_state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
