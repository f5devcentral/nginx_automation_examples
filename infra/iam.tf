# infra/iam.tf

# Create OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["74F3A68F16524F15424927704C9506F55A9316BD"]  # Current thumbprint
}

# IAM Execution Role for CI/CD Pipeline (used by Terraform)
resource "aws_iam_role" "terraform_execution_role" {
  name = "TerraformCIExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::856265587682:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:akananth/nginx_automation_examples:*"
          }
        }
      }
    ]
  })
}

# Policy for managing OIDC providers
resource "aws_iam_policy" "oidc_management" {
  name        = "OIDCProviderManagement"
  description = "Allows management of OpenID Connect providers"

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

# Attach OIDC management policy to execution role
resource "aws_iam_role_policy_attachment" "oidc_management" {
  role       = aws_iam_role.terraform_execution_role.name
  policy_arn = aws_iam_policy.oidc_management.arn
}

# Create IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "GitHubActionsTerraformRole"
  depends_on = [aws_iam_openid_connect_provider.github_oidc]

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::856265587682:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:akananth/nginx_automation_examples:ref:refs/heads/apply-nap"
          }
        }
      }
    ]
  })
}

# Terraform State Management Policy
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

  depends_on = [aws_dynamodb_table.terraform_state_lock]
}

# Attach state policy to GitHub Actions role
resource "aws_iam_role_policy_attachment" "terraform_state_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}

# Attach state policy to execution role
resource "aws_iam_role_policy_attachment" "execution_state_access" {
  role       = aws_iam_role.terraform_execution_role.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}