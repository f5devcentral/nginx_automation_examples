output "oidc_provider_arn" {
  value = length(aws_iam_openid_connect_provider.github_oidc) > 0 ? aws_iam_openid_connect_provider.github_oidc[0].arn : null
}

output "terraform_state_access_policy_arn" {
  value = var.create_policy ? aws_iam_policy.terraform_state_access[0].arn : data.aws_iam_policy.existing_terraform_state_access[0].arn
}

output "terraform_execution_role_arn" {
  value = var.create_role ? aws_iam_role.terraform_execution_role[0].arn : data.aws_iam_role.existing_terraform_execution_role[0].arn
}