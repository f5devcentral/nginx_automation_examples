provider "aws" {
  region = var.aws_region
}

# Check if OIDC Provider already exists
data "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_oidc" {
  count = length(data.aws_iam_openid_connect_provider.github_oidc) > 0 ? 0 : 1

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  lifecycle {
    prevent_destroy = true
  }
}

# IAM Execution Role for Terraform CI/CD
resource "aws_iam_role" "terraform_execution_role" {
  count = length(aws_iam_openid_connect_provider.github_oidc) > 0 ? 1 : 0

  name               = "TerraformCIExecutionRole"
  description        = "Role for basic Terraform CI/CD executions"
  max_session_duration = 3600 # 1 hour maximum

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc[0].arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}

# Check if the IAM Policy already exists
data "aws_iam_policy" "existing_terraform_state_access" {
  name = "TerraformStateAccess"
}

# Conditionally create the IAM Policy if it doesn't exist
resource "aws_iam_policy" "terraform_state_access" {
  count = length(data.aws_iam_policy.existing_terraform_state_access) > 0 ? 0 : 1

  name        = "TerraformStateAccess"
  description = "Minimum permissions for S3 state management"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.tf_state_bucket}",
          "arn:aws:s3:::${var.tf_state_bucket}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "state_access" {
  count = length(aws_iam_role.terraform_execution_role) > 0 ? 1 : 0

  role       = aws_iam_role.terraform_execution_role[0].name
  policy_arn = length(data.aws_iam_policy.existing_terraform_state_access) > 0 ? data.aws_iam_policy.existing_terraform_state_access.arn : aws_iam_policy.terraform_state_access[0].arn
}