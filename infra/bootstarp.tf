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

  # Combined dependencies in single block
  depends_on = [
    aws_iam_role.terraform_execution_role,
    aws_dynamodb_table.terraform_state_lock
  ]
}