# OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["74F3A68F16524F15424927704C9506F55A9316BD"]
}

# IAM Execution Role
resource "aws_iam_role" "terraform_execution_role" {
  name = "TerraformCIExecutionRole"

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
            "token.actions.githubusercontent.com:sub" = "repo:akananth/nginx_automation_examples:*"
          }
        }
      }
    ]
  })
}

# IAM Policy for OIDC Management
resource "aws_iam_policy" "oidc_management" {
  name        = "OIDCProviderManagement"
  description = "Manage OIDC providers"

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

# IAM Policy for State Management
resource "aws_iam_policy" "terraform_state_access" {
  name        = "TerraformStateAccess"
  description = "Access to Terraform state resources"

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
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*",
          aws_dynamodb_table.terraform_state_lock.arn
        ]
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.state,
    aws_dynamodb_table.terraform_state_lock
  ]
}

# IAM Policy Attachments
resource "aws_iam_role_policy_attachment" "oidc_management" {
  role       = aws_iam_role.terraform_execution_role.name
  policy_arn = aws_iam_policy.oidc_management.arn
}

resource "aws_iam_role_policy_attachment" "state_access" {
  role       = aws_iam_role.terraform_execution_role.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}

# GitHub Actions Deployment Role
resource "aws_iam_role" "github_actions" {
  name = "GitHubActionsTerraformRole"

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
            "token.actions.githubusercontent.com:sub" = "repo:akananth/nginx_automation_examples:ref:refs/heads/apply-nap"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_state_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}