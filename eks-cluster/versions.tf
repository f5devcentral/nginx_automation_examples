terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = ">= 4"
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
  backend "s3" {
    bucket         = "akash-terraform-state-bucket"  # Your S3 bucket name
    key            = "eks-cluster/terraform.tfstate"       # Path to state file
    region         = "us-east-1"                     # AWS region
    dynamodb_table = "terraform-lock-table"          # DynamoDB table for state locking
    encrypt        = true  
                           
  }
}
