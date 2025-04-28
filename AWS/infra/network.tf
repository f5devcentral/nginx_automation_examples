# Declare the random_id resource to generate a suffix
resource "random_id" "build_suffix" {
  byte_length = 8
}

# VPC Module Configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.19.0"  # Correct version constraint

  name = "${var.project_prefix}-vpc-${random_id.build_suffix.hex}"
  cidr = var.cidr
  azs  = local.azs

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name           = "${var.project_prefix}-vpc-${random_id.build_suffix.hex}"
    resource_owner = var.resource_owner
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.project_prefix}-igw-${random_id.build_suffix.hex}"
  }
}

# Subnets
resource "aws_subnet" "management" {
  for_each          = toset(local.azs)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(module.vpc.vpc_cidr_block, 4, index(local.azs, each.key) * 4)
  availability_zone = each.key
  tags = {
    Name = format("%s-mgmt-subnet-%s", var.project_prefix, each.key)
  }
}

resource "aws_subnet" "internal" {
  for_each          = toset(local.azs)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(module.vpc.vpc_cidr_block, 4, index(local.azs, each.key) * 4 + 1)
  availability_zone = each.key
  tags = {
    Name = format("%s-int-subnet-%s", var.project_prefix, each.key)
  }
}

resource "aws_subnet" "external" {
  for_each                = toset(local.azs)
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = cidrsubnet(module.vpc.vpc_cidr_block, 4, index(local.azs, each.key) * 4 + 2)
  map_public_ip_on_launch = true
  availability_zone       = each.key
  tags = {
    Name = format("%s-ext-subnet-%s", var.project_prefix, each.key)
  }
}

resource "aws_subnet" "app_cidr" {
  for_each          = toset(local.azs)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(module.vpc.vpc_cidr_block, 4, index(local.azs, each.key) * 4 + 3)
  availability_zone = each.key
  tags = {
    Name = format("%s-app-subnet-%s", var.project_prefix, each.key)
  }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project_prefix}-rt-${random_id.build_suffix.hex}"
  }
}

# Route Table Associations
resource "aws_route_table_association" "subnet-association-internal" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.internal[each.key].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-association-management" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.management[each.key].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-association-external" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.external[each.key].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-association-app-cidr" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.app_cidr[each.key].id
  route_table_id = aws_route_table.main.id
}