# outputs.tf
output "aws_region" {
  value = var.aws_region
}
output "azs" {
  value = var.azs
}
output "aws_access_key_id" {
  description = "AWS Access Key ID"
  value       = data.tfe_outputs.infra.values.aws_access_key_id
  sensitive   = true
}

output "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  value       = data.tfe_outputs.infra.values.aws_secret_access_key
  sensitive   = true
}

output "aws_session_token" {
  description = "AWS Session Token"
  value       = data.tfe_outputs.infra.values.aws_session_token
  sensitive   = true
}

output "copy_policy_complete" {
  description = "Indicates that the compiled policy has been copied"
  value       = null_resource.copy_compiled_policy.id
}