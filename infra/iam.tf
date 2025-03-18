# OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd" # GitHub's current thumbprint
  ]

  lifecycle {
    prevent_destroy = true
  }
}

# IAM Policy for OIDC Management
resource "aws_iam_policy" "oidc_management" {
  name        = "OIDCProviderManagement"
  description = "Permissions to manage GitHub OIDC provider"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders"
        ],
        Resource = "*"
      }
    ]
  })
}

# Admin Role for Bootstrap
resource "aws_iam_role" "admin_role" {
  name = "TerraformBootstrapAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::856265587682:root" # Replace with your account ID
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach OIDC Management Policy to Admin Role
resource "aws_iam_role_policy_attachment" "oidc_management" {
  role       = aws_iam_role.admin_role.name
  policy_arn = aws_iam_policy.oidc_management.arn
}

# IAM Execution Role for Terraform CI/CD
resource "aws_iam_role" "terraform_execution_role" {
  name               = "TerraformCIExecutionRole"
  description        = "Role for basic Terraform CI/CD executions"
  max_session_duration = 3600 # 1 hour maximum

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
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
}

# Minimal S3 Access Policy
resource "aws_iam_policy" "terraform_state_access" {
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
          "arn:aws:s3:::akash-terraform-state-bucket",
          "arn:aws:s3:::akash-terraform-state-bucket/*"
        ]
      }
    ]
  })
}

# Attach S3 Access Policy to Execution Role
resource "aws_iam_role_policy_attachment" "state_access" {
  role       = aws_iam_role.terraform_execution_role.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}