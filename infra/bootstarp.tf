terraform {
    required_version = ">= 1.5.0"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 5.0"
      }
    }
  
    backend "s3" {
      bucket         = "akash-terraform-state-bucket"
      key            = "infra/terraform.tfstate"
      region         = "us-east-1"
      dynamodb_table = "terraform-lock-table"
      encrypt        = true
    }
  }
  
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