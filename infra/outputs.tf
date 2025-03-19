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
  value = module.vpc.main_route_table_id
}

# Subnet Information
output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "management_subnet_ids" {
  value = module.vpc.management_subnets
}

output "public_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "private_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "management_cidr_blocks" {
  value = module.vpc.management_subnets_cidr_blocks
}

output "public_az1_cidr_block" {
  value = module.vpc.public_subnets_cidr_blocks[0]
}

output "private_az1_cidr_block" {
  value = module.vpc.private_subnets_cidr_blocks[0]
}

# CIDR Block for Application and EKS Subnets
output "app_cidr" {
  description = "Application server (Juice Shop) CIDR block"
  value       = module.vpc.subnet_addrs["app-cidr"].network_cidr_blocks
}

output "eks_cidr" {
  description = "EKS server CIDR block"
  value       = module.vpc.subnet_addrs["eks-cidr"].network_cidr_blocks
}

# External, Internal, Management Subnet AZ Information
output "ext_subnet_az1" {
  description = "ID of External subnet AZ1"
  value       = module.vpc.public_subnets[0]
}

output "ext_subnet_az2" {
  description = "ID of External subnet AZ2"
  value       = module.vpc.public_subnets[1]
}

output "int_subnet_az1" {
  description = "ID of Internal subnet AZ1"
  value       = module.vpc.private_subnets[0]
}

output "int_subnet_az2" {
  description = "ID of Internal subnet AZ2"
  value       = module.vpc.private_subnets[1]
}

output "mgmt_subnet_az1" {
  description = "ID of Management subnet AZ1"
  value       = module.vpc.management_subnets[0]
}

output "mgmt_subnet_az2" {
  description = "ID of Management subnet AZ2"
  value       = module.vpc.management_subnets[1]
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

# S3 Bucket Output
output "s3_bucket_created" {
  description = "Whether the S3 bucket was created."
  value       = length(aws_s3_bucket.state) > 0 ? true : false
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket."
  value       = length(aws_s3_bucket.state) > 0 ? aws_s3_bucket.state[0].bucket : data.aws_s3_bucket.existing_state_bucket.bucket
}

# DynamoDB Output
output "dynamodb_table_created" {
  description = "Whether the DynamoDB table was created."
  value       = length(aws_dynamodb_table.terraform_state_lock) > 0 ? true : false
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = length(aws_dynamodb_table.terraform_state_lock) > 0 ? aws_dynamodb_table.terraform_state_lock[0].name : data.aws_dynamodb_table.existing_terraform_state_lock.name
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
