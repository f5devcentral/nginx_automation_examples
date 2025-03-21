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

output "iam_role_created" {
  description = "Whether the IAM role was created."
  value       = length(aws_iam_role.terraform_execution_role) > 0
}

output "iam_policy_created" {
  description = "Whether the IAM policy was created."
  value       = length(aws_iam_policy.terraform_state_access) > 0
}

output "iam_role_name" {
  description = "The name of the IAM role."
  value = coalesce(
    try(aws_iam_role.terraform_execution_role[0].name, ""),
    try(data.aws_iam_role.existing_terraform_execution_role[0].name, "")
  )
}

output "iam_policy_name" {
  description = "The name of the IAM policy."
  value = coalesce(
    try(aws_iam_policy.terraform_state_access[0].name, ""),
    try(data.aws_iam_policy.existing_terraform_state_access[0].name, "")
  )
}