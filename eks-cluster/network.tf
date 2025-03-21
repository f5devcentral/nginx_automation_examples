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

# Calculate subnet CIDR blocks
module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = local.eks_cidr  # Use the dedicated EKS CIDR block
  networks = [
    {
      name     = "eks-internal"
      new_bits = 1  # Adds 1 bit to the base CIDR block
    },
    {
      name     = "eks-external"
      new_bits = 1  # Adds 1 bit to the base CIDR block
    }
  ]
}

# Create EKS internal subnets
resource "aws_subnet" "eks-internal" {
  for_each          = toset(local.azs)
  vpc_id            = local.vpc_id
  cidr_block        = module.subnet_addrs.network_cidr_blocks["eks-internal"][index(local.azs, each.key)]
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
  cidr_block              = module.subnet_addrs.network_cidr_blocks["eks-external"][index(local.azs, each.key)]
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