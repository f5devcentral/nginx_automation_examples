terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = ">= 4"
  }
  backend "s3" {
    bucket         = "akash-terraform-state-bucket"  # Your S3 bucket name
    key            = "infra/terraform.tfstate"       # Path to state file
    region         = "us-east-1"                     # AWS region
    dynamodb_table = "terraform-lock-table"          # DynamoDB table for state locking
    encrypt        = true                            # Encrypt state file at rest
  }
}