data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket =  "your-unique-bucket-name"       # Your S3 bucket name
    key    = "infra/terraform.tfstate"       # Path to infra's state file
    region = "us-east-1"                     # AWS region
  }
}

