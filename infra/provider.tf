# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}
terraform {
  backend "local" {}  # Use local state for bootstrapping
}

