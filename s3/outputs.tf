# S3 Bucket Details
output "s3_bucket_created" {
  description = "Whether the S3 bucket was created."
  value       = length(aws_s3_bucket.terraform_state_bucket) > 0 ? true : false
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket."
  value       = length(aws_s3_bucket.terraform_state_bucket) > 0 ? aws_s3_bucket.terraform_state_bucket[0].bucket : null
}

# DynamoDB Table Details
output "dynamodb_table_created" {
  description = "Whether the DynamoDB table was created."
  value       = length(aws_dynamodb_table.terraform_state_lock) > 0 ? true : false
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = length(aws_dynamodb_table.terraform_state_lock) > 0 ? aws_dynamodb_table.terraform_state_lock[0].name : null
}

# Output the ARN of the created IAM role (if created)
output "terraform_execution_role_arn" {
  description = "The ARN of the IAM role created for Terraform CI/CD executions."
  value       = var.create_iam_resources ? aws_iam_role.terraform_execution_role[0].arn : null
}

# Output the ARN of the created IAM policy (if created)
output "terraform_state_access_policy_arn" {
  description = "The ARN of the IAM policy created for Terraform state access."
  value       = var.create_iam_resources ? aws_iam_policy.terraform_state_access[0].arn : null
}

# Output the name of the created IAM role (if created)
output "terraform_execution_role_name" {
  description = "The name of the IAM role created for Terraform CI/CD executions."
  value       = var.create_iam_resources ? aws_iam_role.terraform_execution_role[0].name : null
}

# Output the name of the created IAM policy (if created)
output "terraform_state_access_policy_name" {
  description = "The name of the IAM policy created for Terraform state access."
  value       = var.create_iam_resources ? aws_iam_policy.terraform_state_access[0].name : null
}

# Output the ID of the AWS account (for reference)
output "aws_account_id" {
  description = "The ID of the AWS account where the resources are being created."
  value       = data.aws_caller_identity.current.account_id
}