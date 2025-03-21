terraform {
  backend "local" {
    path = "bootstrap.tfstate"
  }
}


# Check for existing S3 bucket
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.tf_state_bucket
}

# Check for existing DynamoDB table
data "aws_dynamodb_table" "existing_lock_table" {
  name = "terraform-lock-table"
}

# S3 Bucket Configuration
resource "aws_s3_bucket" "terraform_state_bucket" {
  count = can(data.aws_s3_bucket.existing_bucket.id) ? 0 : 1

  bucket        = var.tf_state_bucket
  force_destroy = true

  tags = {
    Name = "Terraform State Bucket"
  }
}

resource "aws_s3_bucket_versioning" "state_bucket" {
  count = can(data.aws_s3_bucket.existing_bucket.id) ? 0 : 1

  bucket = aws_s3_bucket.terraform_state_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket" {
  count = can(data.aws_s3_bucket.existing_bucket.id) ? 0 : 1

  bucket = aws_s3_bucket.terraform_state_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB Table Configuration
resource "aws_dynamodb_table" "terraform_state_lock" {
  count = can(data.aws_dynamodb_table.existing_lock_table.id) ? 0 : 1

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