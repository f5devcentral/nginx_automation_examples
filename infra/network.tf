############################ VPC ############################

# Create VPC, subnets, route tables, and IGW
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  valid_azs = [for az in data.aws_availability_zones.available.names : az if az != "us-west-1a"]
}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = ">= 4.0"
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

resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id
  tags   = {
    Name = "${var.project_prefix}-igw-${random_id.build_suffix.hex}"
  }
}

module subnet_addrs {
  for_each = toset(local.valid_azs)
  source          = "hashicorp/subnets/cidr"
  version         = ">= 1.0.0"
  base_cidr_block = cidrsubnet(module.vpc.vpc_cidr_block,4,index(local.valid_azs,each.key))
  networks        = [
    { name = "management", new_bits = 8 },
    { name = "internal", new_bits = 6 },
    { name = "external", new_bits = 6 },
    { name = "app-cidr", new_bits = 4 }
  ]
}

resource "aws_subnet" "internal" {
  for_each         = toset(local.valid_azs)
  vpc_id           = module.vpc.vpc_id
  cidr_block       = module.subnet_addrs[each.key].network_cidr_blocks["internal"]
  availability_zone = each.key
  tags = { Name = format("%s-int-subnet-%s", var.project_prefix, each.key) }
}

resource "aws_subnet" "management" {
  for_each         = toset(local.valid_azs)
  vpc_id           = module.vpc.vpc_id
  cidr_block       = module.subnet_addrs[each.key].network_cidr_blocks["management"]
  availability_zone = each.key
  tags = { Name = format("%s-mgmt-subnet-%s", var.project_prefix, each.key) }
}

resource "aws_subnet" "external" {
  for_each         = toset(local.valid_azs)
  vpc_id           = module.vpc.vpc_id
  cidr_block       = module.subnet_addrs[each.key].network_cidr_blocks["external"]
  map_public_ip_on_launch = true
  availability_zone = each.key
  tags = { Name = format("%s-ext-subnet-%s", var.project_prefix, each.key) }
}

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

resource "aws_route_table_association" "subnet-association-internal" {
  for_each       = toset(local.valid_azs)
  subnet_id      = aws_subnet.internal[each.key].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-association-management" {
  for_each       = toset(local.valid_azs)
  subnet_id      = aws_subnet.management[each.key].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-association-external" {
  for_each       = toset(local.valid_azs)
  subnet_id      = aws_subnet.external[each.key].id
  route_table_id = aws_route_table.main.id
}

