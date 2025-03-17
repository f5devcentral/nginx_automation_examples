# modules/infra/network.tf
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  valid_azs = [for az in data.aws_availability_zones.available.names : az if az != "us-west-1a"]
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

# Use the existing VPC if create_vpc is false
data "aws_vpc" "existing" {
  count = var.create_vpc ? 0 : 1
  id    = var.vpc_id
}

# Use the existing subnets if create_vpc is false
data "aws_subnet" "existing_public" {
  count = var.create_vpc ? 0 : length(var.public_subnet_ids)
  id    = var.public_subnet_ids[count.index]
}

data "aws_subnet" "existing_private" {
  count = var.create_vpc ? 0 : length(var.private_subnet_ids)
  id    = var.private_subnet_ids[count.index]
}

data "aws_subnet" "existing_management" {
  count = var.create_vpc ? 0 : length(var.management_subnet_ids)
  id    = var.management_subnet_ids[count.index]
}

# Use the existing internet gateway (if it exists)
data "aws_internet_gateway" "existing" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

# Create a new internet gateway if one does not exist
resource "aws_internet_gateway" "igw" {
  count  = var.create_vpc ? 1 : (length(data.aws_internet_gateway.existing) == 0 ? 1 : 0)
  vpc_id = var.create_vpc ? module.vpc.vpc_id : var.vpc_id
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