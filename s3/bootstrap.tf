terraform {
  backend "local" {
    path = "bootstrap.tfstate"
  }
}

# Check if S3 bucket exists using AWS CLI (no Terraform errors)
data "external" "s3_bucket_exists" {
  program = ["bash", "-c", <<EOT
    if aws s3api head-bucket --bucket ${var.tf_state_bucket} >/dev/null 2>&1; then
      echo '{"exists":"true"}'
    else
      echo '{"exists":"false"}'
    fi
  EOT
  ]
}

# Check if DynamoDB table exists using AWS CLI (no Terraform errors)
data "external" "dynamodb_table_exists" {
  program = ["bash", "-c", <<EOT
    if aws dynamodb describe-table --table-name terraform-lock-table >/dev/null 2>&1; then
      echo '{"exists":"true"}'
    else
      echo '{"exists":"false"}'
    fi
  EOT
  ]
}

# Create S3 bucket only if it doesn't exist
resource "aws_s3_bucket" "terraform_state_bucket" {
  count = data.external.s3_bucket_exists.result.exists == "true" ? 0 : 1

  bucket        = var.tf_state_bucket
  force_destroy = true  # Allow deletion even if not empty

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Create DynamoDB table only if it doesn't exist
resource "aws_dynamodb_table" "terraform_state_lock" {
  count = data.external.dynamodb_table_exists.result.exists == "true" ? 0 : 1

  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}