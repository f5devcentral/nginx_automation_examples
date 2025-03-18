terraform {
    required_version = ">= 1.0.0"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 5.0"
      }
      random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
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
  