data "external" "s3_bucket_check" {
  program = ["bash", "-c", <<EOT
    if aws s3api head-bucket --bucket ${var.tf_state_bucket} --region ${var.aws_region} >/dev/null 2>&1; then
      printf '{"exists":"true"}'
    else
      printf '{"exists":"false"}'
    fi
  EOT
  ]
}

data "external" "dynamodb_table_check" {
  program = ["bash", "-c", <<EOT
    if aws dynamodb describe-table --table-name terraform-lock-table --region ${var.aws_region} >/dev/null 2>&1; then
      printf '{"exists":"true"}'
    else
      printf '{"exists":"false"}'
    fi
  EOT
  ]
}

# Create S3 bucket only if missing
resource "aws_s3_bucket" "terraform_state_bucket" {
  count = data.external.s3_bucket_check.result.exists == "true" ? 0 : 1

  bucket        = var.tf_state_bucket
  force_destroy = true

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Configure bucket versioning
resource "aws_s3_bucket_versioning" "state_bucket" {
  count = data.external.s3_bucket_check.result.exists == "true" ? 0 : 1

  bucket = aws_s3_bucket.terraform_state_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket" {
  count = data.external.s3_bucket_check.result.exists == "true" ? 0 : 1

  bucket = aws_s3_bucket.terraform_state_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create DynamoDB table only if missing
resource "aws_dynamodb_table" "terraform_state_lock" {
  count = data.external.dynamodb_table_check.result.exists == "true" ? 0 : 1

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