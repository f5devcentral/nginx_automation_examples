data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket =  var.AWS_S3_BUCKET_NAME       # Your S3 bucket name
    key    = "infra/terraform.tfstate"       # Path to infra's state file
    region = var.AWS_REGION                    # AWS region
  }
}

