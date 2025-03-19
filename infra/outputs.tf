# Global Outputs
output "project_prefix" {
  value = var.project_prefix
}

output "resource_owner" {
  value = var.resource_owner
}

output "build_suffix" {
  value = random_id.build_suffix.hex
}

# AWS Region and Availability Zones
output "aws_region" {
  value = var.aws_region
}

output "azs" {
  value = var.azs
}

# VPC Details
output "vpc_cidr_block" {
  description = "CIDR Block"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_main_route_table_id" {
  value = aws_route_table.main.id  # Reference the route table directly created
}

# Subnet Information
output "public_subnet_ids" {
  value = [for subnet in aws_subnet.external : subnet.id]  # Reference the external subnets directly
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.internal : subnet.id]  # Reference the internal subnets directly
}

output "management_subnet_ids" {
  value = [for subnet in aws_subnet.management : subnet.id]  # Reference the management subnets directly
}

output "public_cidr_blocks" {
  value = [for subnet in aws_subnet.external : subnet.cidr_block]  # Directly reference external subnets CIDR
}

output "private_cidr_blocks" {
  value = [for subnet in aws_subnet.internal : subnet.cidr_block]  # Directly reference internal subnets CIDR
}

output "management_cidr_blocks" {
  value = [for subnet in aws_subnet.management : subnet.cidr_block]  # Directly reference management subnets CIDR
}

output "public_az1_cidr_block" {
  value = aws_subnet.external[0].cidr_block  # Directly reference AZ1's public CIDR
}

output "private_az1_cidr_block" {
  value = aws_subnet.internal[0].cidr_block  # Directly reference AZ1's private CIDR
}

# CIDR Block for Application and EKS Subnets
output "app_cidr" {
  description = "Application server (Juice Shop) CIDR block"
  value       = [for subnet in aws_subnet.app_cidr : subnet.cidr_block]  # Direct reference to app subnets
}

output "eks_cidr" {
  description = "EKS server CIDR block"
  value       = [for subnet in aws_subnet.internal : subnet.cidr_block]  # Direct reference to EKS subnets
}

# External, Internal, Management Subnet AZ Information
output "ext_subnet_az1" {
  description = "ID of External subnet AZ1"
  value       = aws_subnet.external[0].id  # Direct reference to external AZ1 subnet ID
}

output "ext_subnet_az2" {
  description = "ID of External subnet AZ2"
  value       = aws_subnet.external[1].id  # Direct reference to external AZ2 subnet ID
}

output "int_subnet_az1" {
  description = "ID of Internal subnet AZ1"
  value       = aws_subnet.internal[0].id  # Direct reference to internal AZ1 subnet ID
}

output "int_subnet_az2" {
  description = "ID of Internal subnet AZ2"
  value       = aws_subnet.internal[1].id  # Direct reference to internal AZ2 subnet ID
}

output "mgmt_subnet_az1" {
  description = "ID of Management subnet AZ1"
  value       = aws_subnet.management[0].id  # Direct reference to management AZ1 subnet ID
}

output "mgmt_subnet_az2" {
  description = "ID of Management subnet AZ2"
  value       = aws_subnet.management[1].id  # Direct reference to management AZ2 subnet ID
}

# Security Groups
output "external_sg_id" {
  value = aws_security_group.external.id
}

output "management_sg_id" {
  value = aws_security_group.management.id
}

output "internal_sg_id" {
  value = aws_security_group.internal.id
}

output "s3_bucket_created" {
  description = "Whether the S3 bucket was created."
  value       = length(data.aws_s3_bucket.existing_state_bucket.bucket) > 0 ? true : false
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket."
  value       = data.aws_s3_bucket.existing_state_bucket.bucket
}

output "dynamodb_table_created" {
  description = "Whether the DynamoDB table was created."
  value       = length(data.aws_dynamodb_table.existing_terraform_state_lock.name) > 0 ? true : false
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = data.aws_dynamodb_table.existing_terraform_state_lock.name
}

# IAM Role Output
output "iam_role_created" {
  description = "Whether the IAM role was created."
  value       = length(aws_iam_role.terraform_execution_role) > 0 ? true : false
}

output "iam_role_name" {
  description = "The name of the IAM role."
  value       = length(aws_iam_role.terraform_execution_role) > 0 ? aws_iam_role.terraform_execution_role[0].name : data.aws_iam_role.existing_terraform_execution_role.name
}

# IAM Policy Output
output "iam_policy_created" {
  description = "Whether the IAM policy was created."
  value       = length(aws_iam_policy.terraform_state_access) > 0 ? true : false
}

output "iam_policy_name" {
  description = "The name of the IAM policy."
  value       = length(aws_iam_policy.terraform_state_access) > 0 ? aws_iam_policy.terraform_state_access[0].name : data.aws_iam_policy.existing_terraform_state_access.name
}
