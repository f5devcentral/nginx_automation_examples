terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = ">= 4"
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
  
}
