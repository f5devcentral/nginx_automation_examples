# modules/infra/network.tf
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  valid_azs = [for az in data.aws_availability_zones.available.names : az if az != "us-west-1a"]
}

# Automatically detect the default VPC
data "aws_default_vpc" "default" {
  count = var.create_vpc ? 0 : 1
}

# Automatically detect the default subnets (only if create_vpc is false)
data "aws_subnets" "default" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [data.aws_default_vpc.default[0].id]
  }
}

# Create a new VPC if create_vpc is true
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.0"

  create_vpc = var.create_vpc

  name                 = "${var.project_prefix}-vpc-${random_id.build_suffix.hex}"
  cidr                 = var.cidr
  azs                  = local.valid_azs
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    resource_owner = var.resource_owner
    Name          = "${var.project_prefix}-vpc-${random_id.build_suffix.hex}"
  }
}

# Use local values to handle conditional logic
locals {
  vpc_id    = var.create_vpc ? module.vpc.vpc_id : try(data.aws_default_vpc.default[0].id, "")
  subnet_ids = var.create_vpc ? [] : try(data.aws_subnets.default[0].ids, [])
}

# Create a new internet gateway if one does not exist
resource "aws_internet_gateway" "igw" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = local.vpc_id
  tags   = {
    Name = "${var.project_prefix}-igw-${random_id.build_suffix.hex}"
  }
}

# Use the existing route table or create a new one
resource "aws_route_table" "main" {
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.create_vpc ? aws_internet_gateway.igw[0].id : data.aws_default_vpc.default[0].main_route_table_id
  }
  tags = {
    Name = "${var.project_prefix}-rt-${random_id.build_suffix.hex}"
  }
}

# Associate subnets with the route table
resource "aws_route_table_association" "subnet-association" {
  for_each       = var.create_vpc ? toset([]) : toset(local.subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.main.id
}