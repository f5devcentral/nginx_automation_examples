  resource "aws_s3_bucket" "state" {
    bucket = "akash-terraform-state-bucket"
    tags = {
      Name = "Terraform State Storage"
    }
  
    lifecycle {
      prevent_destroy = true
    }
  }
  
  resource "aws_s3_bucket_versioning" "state" {
    bucket = aws_s3_bucket.state.id
    versioning_configuration {
      status = "Enabled"
    }
  }
  
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