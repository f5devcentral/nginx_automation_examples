# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "akash-terraform-state-bucket"  # Use the existing bucket
    key            = "infra/terraform.tfstate"       # State file path
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"          # Existing DynamoDB table
    encrypt        = true
  }
}

