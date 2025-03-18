# infra/iam.tf

# Create OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub's OIDC thumbprint
}

# Create IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "GitHubActionsTerraformRole"

  # Explicit dependency to ensure OIDC provider is created first
  depends_on = [aws_iam_openid_connect_provider.github_oidc]

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

# Define Terraform state access policy (least privilege)
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
          "arn:aws:dynamodb:us-east-1:*:table/terraform-lock-table"
        ]
      }
    ]
  })
}

# Attach state management policy to role
resource "aws_iam_role_policy_attachment" "terraform_state_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}