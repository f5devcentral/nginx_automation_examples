# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {
    bucket         = "akash-terraform-state-bucket" # The bucket must already exist
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table" # Use DynamoDB for state locking
  }
}