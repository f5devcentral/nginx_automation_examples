
# Safe S3 bucket existence check with proper error handling
data "external" "bucket_check" {
  program = ["bash", "-c", <<EOT
    # Ensure consistent JSON output
    output=$(aws s3api head-bucket --bucket ${var.AWS_S3_BUCKET_NAME} --region ${var.AWS_REGION} 2>&1)
    status=$?
    
    if [ $status -eq 0 ]; then
      echo '{"exists":"true", "message":"Bucket exists"}'
    elif echo "$output" | grep -q '404'; then
      echo '{"exists":"false", "message":"Bucket not found"}'
    else
      echo '{"exists":"error", "message":"'$(echo "$output" | tr -d '\n')'"}'
      exit 1
    fi
  EOT
  ]
}

# Safe DynamoDB table existence check
data "external" "dynamodb_table_check" {
  program = ["bash", "-c", <<EOT
    if output=$(aws dynamodb describe-table \
      --table-name terraform-lock-table \
      --region ${var.AWS_REGION} 2>&1); then
      echo '{"exists":"true"}'
    elif echo "$output" | grep -q 'ResourceNotFoundException'; then
      echo '{"exists":"false"}'
    else
      echo '{"exists":"error", "message":"'$(echo "$output" | tr -d '\n')'"}'
      exit 1
    fi
  EOT
  ]
}

locals {
  # Handle bucket existence with error checking
  bucket_exists = try(
    data.external.bucket_check.result.exists == "true",
    false
  )
  
  # Handle DynamoDB existence with error checking
  dynamodb_exists = try(
    data.external.dynamodb_table_check.result.exists == "true",
    false
  )
  
  # Generate unique bucket name if needed
  # unique_bucket_name = "${var.AWS_S3_BUCKET_NAME}-${data.aws_caller_identity.current.account_id}"
}

# S3 Bucket Resources
resource "aws_s3_bucket" "terraform_state" {
  count = local.bucket_exists ? 0 : 1

  bucket        = var.AWS_S3_BUCKET_NAME
  force_destroy = false

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Global"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state_bucket" {
  count = local.bucket_exists ? 0 : 1

  bucket = aws_s3_bucket.terraform_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket" {
  count = local.bucket_exists ? 0 : 1

  bucket = aws_s3_bucket.terraform_state[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  count = local.dynamodb_exists ? 0 : 1

  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Global"
  }

  lifecycle {
    prevent_destroy = true
  }
}
