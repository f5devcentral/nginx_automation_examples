output "oidc_provider_arn" {
  value = length(aws_iam_openid_connect_provider.github_oidc) > 0 ? aws_iam_openid_connect_provider.github_oidc[0].arn : null
}

output "terraform_execution_role_arn" {
  value = length(aws_iam_role.terraform_execution_role) > 0 ? aws_iam_role.terraform_execution_role[0].arn : null
}

output "terraform_state_access_policy_arn" {
  value = length(data.aws_iam_policy.existing_terraform_state_access) > 0 ? data.aws_iam_policy.existing_terraform_state_access.arn : aws_iam_policy.terraform_state_access[0].arn
}
