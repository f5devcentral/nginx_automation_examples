# infra/iam.tf (Consolidated)

# Create OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Create IAM role for GitHub Actions (merged configuration)
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
          # Combine conditions from both files
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:akananth/nginx_automation_examples:*",
              "repo:akananth/nginx_automation_examples:ref:refs/heads/apply-nap"
            ]
          }
        }
      }
    ]
  })
}

# Attach Terraform state management policy (renamed for clarity)
resource "aws_iam_role_policy_attachment" "terraform_state_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}

# Define Terraform state access policy (unchanged)
resource "aws_iam_policy" "terraform_state_access" {
  name        = "TerraformStateAccess"
  description = "Access to S3 and DynamoDB for Terraform state"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "dynamodb:*"
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