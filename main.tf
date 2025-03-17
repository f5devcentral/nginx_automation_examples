# Root module main.tf
provider "aws" {
  region = var.aws_region
}

module "infra" {
  source = "./infra"

  # Pass input variables to the infra module
  project_prefix          = "aws-akash"
  resource_owner          = "akash"
  aws_region              = "us-east-1"
  azs                     = ["us-east-1a", "us-east-1b"]
  cidr                    = "10.0.0.0/16"
  create_nat_gateway      = false
  admin_src_addr          = "0.0.0.0/0"
  mgmt_address_prefixes   = ["10.1.1.0/24", "10.1.100.0/24"]
  ext_address_prefixes    = ["10.1.10.0/24", "10.1.110.0/24"]
  int_address_prefixes    = ["10.1.20.0/24", "10.1.120.0/24"]
  nap                     = true
  nic                     = false
}

module "eks_cluster" {
  source = "./eks-cluster"

  # Pass outputs from the infra module as input variables
  project_prefix          = module.infra.project_prefix
  resource_owner          = module.infra.resource_owner
  build_suffix            = module.infra.build_suffix
  aws_region              = module.infra.aws_region
  azs                     = module.infra.azs
  vpc_id                  = module.infra.vpc_id
  vpc_main_route_table_id = module.infra.vpc_main_route_table_id
  public_subnet_ids       = module.infra.public_subnet_ids
  eks_cidr                = module.infra.eks_cidr
  internal_sg_id          = module.infra.internal_sg_id
}