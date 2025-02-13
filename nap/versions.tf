terraform {
  required_version = ">= 1.6.0" # Update to the latest stable Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.2"
    }
  }
}

