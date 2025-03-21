
data "aws_caller_identity" "current" {}

# Fetch the existing IAM role for Terraform CI/CD if it exist
data "aws_iam_role" "existing_terraform_execution_role" {
  count = var.create_iam_resources ? 1 : 0
  name  = "TerraformCIExecutionRole"
}

# Fetch the existing IAM policy for Terraform state access if it exists
data "aws_iam_policy" "existing_terraform_state_access" {
  count = var.create_iam_resources ? 1 : 0
  name  = "TerraformStateAccess" # Changed from arn to name lookup
}

resource "aws_iam_role" "terraform_execution_role" {
  count = var.create_iam_resources && length(data.aws_iam_role.existing_terraform_execution_role) == 0 ? 1 : 0

  name               = "TerraformCIExecutionRole"
  description        = "Role for basic Terraform CI/CD executions"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for Terraform state access (if it doesn't exist)
resource "aws_iam_policy" "terraform_state_access" {
  count = var.create_iam_resources && length(data.aws_iam_policy.existing_terraform_state_access) == 0 ? 1 : 0

  name        = "TerraformStateAccess"
  description = "Minimum permissions for S3 state management"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::${var.tf_state_bucket}",
        "arn:aws:s3:::${var.tf_state_bucket}/*"
      ]
    }]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "state_access" {
  count = var.create_iam_resources ? 1 : 0

  role       = coalesce(
    try(data.aws_iam_role.existing_terraform_execution_role[0].name, ""),
    try(aws_iam_role.terraform_execution_role[0].name, "")
  )
  policy_arn = coalesce(
    try(data.aws_iam_policy.existing_terraform_state_access[0].arn, ""),
    try(aws_iam_policy.terraform_state_access[0].arn, "")
  )
}