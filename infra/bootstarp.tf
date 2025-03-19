# Use the existing S3 bucket for the backend
terraform {
  backend "s3" {
    bucket         = "akash-terraform-state-bucket" # The bucket must already exist
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}

# Fetch existing S3 bucket for Terraform state
data "aws_s3_bucket" "existing_state_bucket" {
  bucket = "akash-terraform-state-bucket"
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
}

# Enable versioning for the S3 bucket (only if the bucket is created)
resource "aws_s3_bucket_versioning" "state" {
  count = length(aws_s3_bucket.state) > 0 ? 1 : 0

  bucket = aws_s3_bucket.state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure public access block for the S3 bucket (only if the bucket is created)
resource "aws_s3_bucket_public_access_block" "state" {
  count = length(aws_s3_bucket.state) > 0 ? 1 : 0

  bucket = aws_s3_bucket.state[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create DynamoDB table for Terraform state locking (only if it doesn't exist)
data "aws_dynamodb_table" "existing_terraform_state_lock" {
  name = "terraform-lock-table"
}

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
