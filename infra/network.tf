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

# Automatically detect the default subnets
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


# Use the default VPC if create_vpc is false
locals {
  vpc_id = var.create_vpc ? module.vpc.vpc_id : data.aws_default_vpc.default[0].id
  subnet_ids = var.create_vpc ? [] : data.aws_subnets.default[0].ids
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
  vpc_id = var.create_vpc ? module.vpc.vpc_id : var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.create_vpc ? aws_internet_gateway.igw[0].id : data.aws_internet_gateway.existing[0].id
  }
  tags = {
    Name = "${var.project_prefix}-rt-${random_id.build_suffix.hex}"
  }
}

# Associate existing subnets with the route table
resource "aws_route_table_association" "subnet-association-internal" {
  for_each       = var.create_vpc ? toset([]) : toset(var.private_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-association-management" {
  for_each       = var.create_vpc ? toset([]) : toset(var.management_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-association-external" {
  for_each       = var.create_vpc ? toset([]) : toset(var.public_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.main.id
}