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

# DynamoDB table for Terraform state locking (use existing table if present)
data "aws_dynamodb_table" "existing_terraform_state_lock" {
  name = "terraform-lock-table"
}

# Declare the random_id resource to generate a suffix (if needed for naming)
resource "random_id" "build_suffix" {
  byte_length = 8
}

# Create DynamoDB table for state locking if not already present
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
