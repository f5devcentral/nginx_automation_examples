
# S3 and Dynamo Outputs
output "s3_bucket_created" {
  value       = !local.bucket_exists
  description = "Whether a new S3 bucket was created"
}

output "s3_bucket_name" {
  value       = local.bucket_exists ? var.AWS_S3_BUCKET_NAME : aws_s3_bucket.terraform_state[0].bucket
  description = "Name of the S3 bucket used for Terraform state"
}

output "dynamodb_table_created" {
  value       = !local.dynamodb_exists
  description = "Whether a new DynamoDB table was created"
}

output "dynamodb_table_name" {
  value       = "terraform-lock-table"
  description = "Name of the DynamoDB table used for state locking"
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
