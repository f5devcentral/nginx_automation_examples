# Create Elastic IP
resource "aws_eip" "main" {
  vpc = true
  tags = {
    resource_owner = local.resource_owner
    Name          = format("%s-eip-%s", local.project_prefix, local.build_suffix)
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = local.public_subnet_ids[0]

  tags = {
    resource_owner = local.resource_owner
    Name          = format("%s-ngw-%s", local.project_prefix, local.build_suffix)
  }
}

# Calculate subnet CIDR blocks using cidrsubnet
locals {
  eks_internal_cidrs = [for i, az in local.azs : cidrsubnet(local.eks_cidr, 2, i)]
  eks_external_cidrs = [for i, az in local.azs : cidrsubnet(local.eks_cidr, 2, length(local.azs) + i)]
}

# Create EKS internal subnets
resource "aws_subnet" "eks-internal" {
  for_each          = toset(local.azs)
  vpc_id            = local.vpc_id
  cidr_block        = local.eks_internal_cidrs[index(local.azs, each.key)]
  availability_zone = each.key
  tags = {
    Name = format("%s-eks-int-subnet-%s", local.project_prefix, each.key)
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# Create EKS external subnets
resource "aws_subnet" "eks-external" {
  for_each                = toset(local.azs)
  vpc_id                  = local.vpc_id
  cidr_block              = local.eks_external_cidrs[index(local.azs, each.key)]
  map_public_ip_on_launch = true
  availability_zone       = each.key
  tags = {
    Name = format("%s-eks-ext-subnet-%s", local.project_prefix, each.key)
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

# Create route table for NAT Gateway
resource "aws_route_table" "main" {
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = format("%s-eks-rt-%s", local.project_prefix, local.build_suffix)
  }
}

# Associate internal subnets with the route table
resource "aws_route_table_association" "internal-subnet-association" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.eks-internal[each.key].id
  route_table_id = aws_route_table.main.id
}

# Associate external subnets with the main route table
resource "aws_route_table_association" "external-subnet-association" {
  for_each       = toset(local.azs)
  subnet_id      = aws_subnet.eks-external[each.key].id
  route_table_id = local.vpc_main_route_table_id
}