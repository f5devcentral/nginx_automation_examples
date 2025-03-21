terraform {
  backend "local" {
    path = "bootstrap.tfstate"
  }
}


# Safe S3 bucket existence check
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.tf_state_bucket
}

# Safe DynamoDB table existence check
data "aws_dynamodb_table" "existing_lock_table" {
  name = "terraform-lock-table"
}

# Conditional S3 bucket creation
resource "aws_s3_bucket" "terraform_state_bucket" {
  count = can(data.aws_s3_bucket.existing_bucket.id) ? 0 : 1

  bucket        = var.tf_state_bucket
  force_destroy = true
  tags = {
    Name = "Terraform State Bucket"
  }
}

# Conditional bucket versioning
resource "aws_s3_bucket_versioning" "state_bucket" {
  count = can(data.aws_s3_bucket.existing_bucket.id) ? 0 : 1

  bucket = aws_s3_bucket.terraform_state_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Conditional encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket" {
  count = can(data.aws_s3_bucket.existing_bucket.id) ? 0 : 1

  bucket = aws_s3_bucket.terraform_state_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Conditional DynamoDB table creation
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