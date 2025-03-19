# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "akash-terraform-state-bucket" # Replace with your S3 bucket name
    key            = "infra/terraform.tfstate"      # Replace with the path to your state file
    region         = "us-east-1"                    # Replace with your AWS region
    dynamodb_table = "terraform-lock-table"         # Replace with your DynamoDB table name
  }
}