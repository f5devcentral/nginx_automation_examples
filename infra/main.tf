#Main
#AWS Provider
provider "aws" {
  region = var.aws_region
}
# Create a random id
resource "random_id" "build_suffix" {
  byte_length = 2
}
terraform {
  backend "s3" {
    # Empty block to be configured via CLI
  }
}