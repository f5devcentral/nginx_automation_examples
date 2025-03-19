# Create S3 bucket for Terraform state if it doesn't already exist
resource "aws_s3_bucket" "terraform_state_bucket" {
  count = var.create_s3_bucket ? 1 : 0

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

  lifecycle {
    prevent_destroy = true
  }
}

# Create DynamoDB table for state locking if it doesn't already exist
resource "aws_dynamodb_table" "terraform_state_lock" {
  count = var.create_dynamodb_table ? 1 : 0

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