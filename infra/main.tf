#Main
#AWS Provider
provider "aws" {
  region = var.aws_region
}
# Create a random id
resource "random_id" "build_suffix" {
  byte_length = 2
}

resource "aws_s3_bucket" "state" {
  bucket = "akash-terraform-state-bucket"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true  # Keep for state recovery
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"  # Free S3-managed encryption
      }
    }
  }

  public_access_block {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}
