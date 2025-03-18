# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Fetch remote state for the oidc module
data "terraform_remote_state" "oidc" {
  backend = "s3"
  config = {
    bucket = "akash-terraform-state-bucket"  # Replace with your S3 bucket name
    key    = "oidc/terraform.tfstate"       # State file path for the oidc module
    region = "us-east-1"                    # Replace with your AWS region
  }
}

# Define locals for shared values
locals {
  oidc_provider_arn            = data.terraform_remote_state.oidc.outputs.oidc_provider_arn
  terraform_execution_role_arn = data.terraform_remote_state.oidc.outputs.terraform_execution_role_arn
  state_access_policy_arn      = data.terraform_remote_state.oidc.outputs.terraform_state_access_policy_arn
}



