# infra/bootstrap.tf
terraform {
    backend "s3" {
      bucket         = "akash-terraform-state-bucket"
      key            = "global/bootstrap/terraform.tfstate"
      region         = "us-east-1"
      dynamodb_table = "terraform-lock-table"
      encrypt        = true
    }
  }
  
# Create S3 bucket for state storage
resource "aws_s3_bucket" "state" {
  bucket = "akash-terraform-state-bucket"
  
  lifecycle {
    prevent_destroy = true
  }
}

# Create DynamoDB table for locking
resource "aws_dynamodb_table" "lock" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Automated state migration
resource "null_resource" "state_migration" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      terraform init -migrate-state -force-copy \
        -backend-config="bucket=akash-terraform-state-bucket" \
        -backend-config="key=infra/terraform.tfstate" \
        -backend-config="region=us-east-1" \
        -backend-config="dynamodb_table=terraform-lock-table" \
        -backend-config="encrypt=true"
    EOT
  }

  depends_on = [
    aws_s3_bucket.state,
    aws_dynamodb_table.lock
  ]
}