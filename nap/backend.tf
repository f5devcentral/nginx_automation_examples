terraform {
  backend "s3" {
    key            = "nap/terraform.tfstate"       # Path to state file
    dynamodb_table = "terraform-lock-table"          # DynamoDB table for state locking
    encrypt        = true                            # Encrypt state file at rest
  }
}
