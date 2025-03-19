# Check if the S3 bucket exists by using the "aws_s3_bucket_object" data source
data "aws_s3_bucket_object" "state_check" {
  bucket = "akash-terraform-state-bucket"
  key    = "dummy-key"  # Placeholder key to check existence
}

# Create the S3 bucket for Terraform state if it doesn't exist
resource "aws_s3_bucket" "state" {
  count = length(data.aws_s3_bucket_object.state_check) == 0 ? 1 : 0

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

  # Ensure DynamoDB table is created before the S3 bucket
  depends_on = [aws_dynamodb_table.terraform_state_lock]
}

# Enable versioning for the S3 bucket (only if the bucket is created)
resource "aws_s3_bucket_versioning" "state" {
  count = length(aws_s3_bucket.state) > 0 ? 1 : 0

  bucket = aws_s3_bucket.state[0].id
  versioning_configuration {
    status = "Enabled"
  }

  # Add dependency to ensure S3 bucket is created before versioning
  depends_on = [aws_s3_bucket.state]
}

# Configure public access block for the S3 bucket (only if the bucket is created)
resource "aws_s3_bucket_public_access_block" "state" {
  count = length(aws_s3_bucket.state) > 0 ? 1 : 0

  bucket = aws_s3_bucket.state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Add dependency to ensure S3 bucket is created before public access block
  depends_on = [aws_s3_bucket.state]
}

# Check if the DynamoDB table exists
data "aws_dynamodb_table" "existing_terraform_state_lock" {
  name = "terraform-lock-table"
}

# Create DynamoDB table for Terraform state locking (only if it doesn't exist)
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
