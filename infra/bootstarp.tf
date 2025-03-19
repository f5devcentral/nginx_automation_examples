# Create S3 bucket for Terraform state
resource "aws_s3_bucket" "state" {
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

# Create DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
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

# Use the created S3 bucket and DynamoDB table for Terraform backend configuration
resource "aws_s3_bucket_object" "backend_config" {
  bucket = aws_s3_bucket.state.bucket
  key    = "terraform.tfstate"
  acl    = "private"
  content = <<-EOF
  terraform {
    backend "s3" {
      bucket = "${aws_s3_bucket.state.bucket}"
      key    = "terraform.tfstate"
      region = "us-west-2" # Replace with your region
      encrypt = true
      dynamodb_table = "${aws_dynamodb_table.terraform_state_lock.name}"
    }
  }
  EOF
}


