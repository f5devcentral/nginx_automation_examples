data "aws_caller_identity" "current" {}

# Create IAM role if it doesn't exist
resource "aws_iam_role" "terraform_execution_role" {
  count = var.create_iam_resources ? 1 : 0

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

# Create IAM policy if it doesn't exist
resource "aws_iam_policy" "terraform_state_access" {
  count = var.create_iam_resources ? 1 : 0

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
        "arn:aws:s3:::${var.AWS_S3_BUCKET_NAME}",
        "arn:aws:s3:::${var.AWS_S3_BUCKET_NAME}/*"
      ]
    }]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "state_access" {
  count = var.create_iam_resources ? 1 : 0

  role       = aws_iam_role.terraform_execution_role[0].name
  policy_arn = aws_iam_policy.terraform_state_access[0].arn
}