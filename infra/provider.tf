# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}