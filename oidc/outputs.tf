# oidc/outputs.tf
output "oidc_provider_arn" {
  value = length(aws_iam_openid_connect_provider.github_oidc) > 0 ? aws_iam_openid_connect_provider.github_oidc[0].arn : null
}

output "terraform_execution_role_arn" {
  value = aws_iam_role.terraform_execution_role.arn
}