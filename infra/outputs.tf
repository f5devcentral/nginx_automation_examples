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
  value = var.AWS_REGION
}

output "azs" {
  value = local.azs
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
  value = [for k, subnet in aws_subnet.external : subnet.id]  # Reference the external subnets directly
}

output "private_subnet_ids" {
  value = [for k, subnet in aws_subnet.internal : subnet.id]  # Reference the internal subnets directly
}

output "management_subnet_ids" {
  value = [for k, subnet in aws_subnet.management : subnet.id]  # Reference the management subnets directly
}

output "public_cidr_blocks" {
  value = [for k, subnet in aws_subnet.external : subnet.cidr_block]  # Directly reference external subnets CIDR
}

output "private_cidr_blocks" {
  value = [for k, subnet in aws_subnet.internal : subnet.cidr_block]  # Directly reference internal subnets CIDR
}

output "management_cidr_blocks" {
  value = [for k, subnet in aws_subnet.management : subnet.cidr_block]  # Directly reference management subnets CIDR
}

# Specific AZ Subnet CIDR Blocks
output "public_az1_cidr_block" {
  value = aws_subnet.external[element(tolist(local.azs), 0)].cidr_block  # Reference AZ1's public CIDR
}

output "private_az1_cidr_block" {
  value = aws_subnet.internal[element(tolist(local.azs), 0)].cidr_block  # Reference AZ1's private CIDR
}

output "public_az2_cidr_block" {
  value = aws_subnet.external[element(tolist(local.azs), 1)].cidr_block  # Reference AZ2's public CIDR
}

output "private_az2_cidr_block" {
  value = aws_subnet.internal[element(tolist(local.azs), 1)].cidr_block  # Reference AZ2's private CIDR
}

# Subnet IDs for specific AZs
output "ext_subnet_az1" {
  value = aws_subnet.external[element(tolist(local.azs), 0)].id  # Reference AZ1's external subnet ID
}

output "ext_subnet_az2" {
  value = aws_subnet.external[element(tolist(local.azs), 1)].id  # Reference AZ2's external subnet ID
}

output "int_subnet_az1" {
  value = aws_subnet.internal[element(tolist(local.azs), 0)].id  # Reference AZ1's internal subnet ID
}

output "int_subnet_az2" {
  value = aws_subnet.internal[element(tolist(local.azs), 1)].id  # Reference AZ2's internal subnet ID
}

output "mgmt_subnet_az1" {
  value = aws_subnet.management[element(tolist(local.azs), 0)].id  # Reference AZ1's management subnet ID
}

output "mgmt_subnet_az2" {
  value = aws_subnet.management[element(tolist(local.azs), 1)].id  # Reference AZ2's management subnet ID
}

# CIDR Block for Application and EKS Subnets
output "app_cidr" {
  description = "Application server (Juice Shop) CIDR block"
  value       = [for k, subnet in aws_subnet.app_cidr : subnet.cidr_block]  # Direct reference to app subnets
}

output "eks_cidr" {
  description = "EKS server CIDR block"
  value       = [cidrsubnet(module.vpc.vpc_cidr_block, 4, 15)]  # Dedicated CIDR block for EKS
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










