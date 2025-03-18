resource "aws_iam_role" "github_actions" {
  name = "GitHubActionsTerraformRole"

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
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" = "repo:akananth/nginx_automation_examples:ref:refs/heads/apply-nap"
          }
        }
      }
    ]
  })
}

# Attach Terraform state policy
resource "aws_iam_role_policy_attachment" "terraform_state" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}