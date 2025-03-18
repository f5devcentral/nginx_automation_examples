# infra/bootstrap.tf

# 1. Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
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

  lifecycle {
    prevent_destroy = true
  }
}

# 2. Bootstrap initialization sequence
resource "null_resource" "state_lock_bootstrap" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      terraform init -reconfigure && \
      terraform apply -target=aws_dynamodb_table.terraform_state_lock -auto-approve
    EOT
  }

  # Ensure proper creation order
  depends_on = [aws_iam_role.terraform_execution_role]
}

# 3. State access policy with explicit dependencies
resource "aws_iam_policy" "terraform_state_access" {
  name        = "TerraformStateAccess"
  description = "Access to S3 and DynamoDB for Terraform state"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = [
          "arn:aws:s3:::akash-terraform-state-bucket",
          "arn:aws:s3:::akash-terraform-state-bucket/*",
          aws_dynamodb_table.terraform_state_lock.arn
        ]
      }
    ]
  })

  # Critical dependency chain
  depends_on = [
    aws_dynamodb_table.terraform_state_lock,
    aws_iam_role.terraform_execution_role
  ]
}