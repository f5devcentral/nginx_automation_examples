terraform {
  required_version = ">= 1.6.0" # Ensures Terraform version is 1.6.0 or later

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.87.0" # Use latest stable AWS provider
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.35.1" # Use latest stable Kubernetes provider
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0" # Use latest stable Helm provider
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0" # Use latest stable Kubectl provider
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.2" # Ensure Docker provider is up-to-date
    }
  }
}

