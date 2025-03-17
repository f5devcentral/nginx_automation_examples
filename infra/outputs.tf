# Global
output "project_prefix" {
  value = var.project_prefix
}

output "resource_owner" {
  value = var.resource_owner
}

output "build_suffix" {
  value = random_id.build_suffix.hex
}

# Outputs
output "aws_region" {
  value = var.aws_region
}

output "azs" {
  value = var.azs
}

output "vpc_cidr_block" {
  description = "CIDR Block"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_main_route_table_id" {
  value = aws_route_table.main.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.external : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.internal : subnet.id]
}

output "management_subnet_ids" {
  value = [for subnet in aws_subnet.management : subnet.id]
}

output "private_cidr_blocks" {
  value = [for subnet in aws_subnet.internal : subnet.cidr_block]
}

output "public_cidr_blocks" {
  value = [for subnet in aws_subnet.external : subnet.cidr_block]
}

output "management_cidr_blocks" {
  value = [for subnet in aws_subnet.management : subnet.cidr_block]
}

output "app_cidr" {
  description = "Application server(Juice Shop) CIDR block"
  value       = values(module.subnet_addrs)[0].network_cidr_blocks.app-cidr
}

output "eks_cidr" {
  description = "Application server(EKS) CIDR block"
  value       = values(module.subnet_addrs)[1].network_cidr_blocks.app-cidr
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "external_sg_id" {
  value = aws_security_group.external.id
}

output "management_sg_id" {
  value = aws_security_group.management.id
}

output "internal_sg_id" {
  value = aws_security_group.internal.id
}

output "nap" {
  value = var.nap
}

output "nic" {
  value = var.nic
}