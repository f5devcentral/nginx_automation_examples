# Declare the random_id resource
resource "random_id" "build_suffix" {
  byte_length = 4
}

# Fetch available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC using module version 5.x
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.0.0"  # Use version 5.x (latest stable)
  name                 = "${var.project_prefix}-vpc-${random_id.build_suffix.hex}"
  vpc_cidr             = var.cidr   # Correct argument name for version 5.x
  azs                  = data.aws_availability_zones.available.names
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name"            = "${var.project_prefix}-vpc-${random_id.build_suffix.hex}"
    "resource_owner"  = var.resource_owner
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.project_prefix}-igw-${random_id.build_suffix.hex}"
  }
}

# Calculate subnet CIDR blocks
resource "aws_subnet" "internal" {
  for_each = toset(data.aws_availability_zones.available.names)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(module.vpc.vpc_cidr_block, 4, index(data.aws_availability_zones.available.names, each.key) * 3)
  availability_zone = each.key
  tags = {
    Name = format("%s-int-subnet-%s", var.project_prefix, each.key)
  }
}

resource "aws_subnet" "management" {
  for_each = toset(data.aws_availability_zones.available.names)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(module.vpc.vpc_cidr_block, 4, index(data.aws_availability_zones.available.names, each.key) * 3 + 1)
  availability_zone = each.key
  tags = {
    Name = format("%s-mgmt-subnet-%s", var.project_prefix, each.key)
  }
}

resource "aws_subnet" "external" {
  for_each = toset(data.aws_availability_zones.available.names)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(module.vpc.vpc_cidr_block, 4, index(data.aws_availability_zones.available.names, each.key) * 3 + 2)
  map_public_ip_on_launch = true
  availability_zone = each.key
  tags = {
    Name = format("%s-ext-subnet-%s", var.project_prefix, each.key)
  }
}

# Create Route Table
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

# Associate Subnets with Route Table
resource "aws_route_table_association" "subnet-association-internal" {
  for_each       = toset(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.internal[each.key].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-association-management" {
  for_each       = toset(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.management[each.key].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet-association-external" {
  for_each       = toset(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.external[each.key].id
  route_table_id = aws_route_table.main.id
}
