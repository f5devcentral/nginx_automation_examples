#Main
#AWS Provider
provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key  # Pass via GitHub Secrets
  secret_key = var.aws_secret_key 
  session_token = var.aws_session_token
}
# Create a random id
resource "random_id" "build_suffix" {
  byte_length = 2
}
