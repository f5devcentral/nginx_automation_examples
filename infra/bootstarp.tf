# Remove the S3 bucket creation
# Remove this block:
# resource "aws_s3_bucket" "state" {
#   bucket = "akash-terraform-state-bucket"
#
#   lifecycle {
#     prevent_destroy = true
#   }
#
#   versioning {
#     enabled = true
#   }
#
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# Use the existing S3 bucket for the backend
terraform {
  backend "s3" {
    bucket         = "akash-terraform-state-bucket" # The bucket must already exist
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}

# The following resources can be used for versioning and access controls if needed
resource "aws_s3_bucket_versioning" "state" {
  bucket = "akash-terraform-state-bucket"

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.state]
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = "akash-terraform-state-bucket"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
