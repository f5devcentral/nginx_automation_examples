# Root module main.tf
provider "aws" {
  region = var.aws_region
}

module "infra" {
  source = "./"

  # Pass input variables to the infra module
  project_prefix          = var.project_prefix
  resource_owner          = var.resource_owner
  aws_region              = var.aws_region
  azs                     = var.azs
  cidr                    = var.cidr
  create_nat_gateway      = var.create_nat_gateway
  admin_src_addr          = var.admin_src_addr
  mgmt_address_prefixes   = var.mgmt_address_prefixes
  ext_address_prefixes    = var.ext_address_prefixes
  int_address_prefixes    = var.int_address_prefixes
  nap                     = var.nap
  nic                     = var.nic
}

module "eks_cluster" {
  source = "./"

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

module "nap" {
  source = "./"

  # Pass outputs from the infra and eks-cluster modules as input variables
  project_prefix          = module.infra.project_prefix
  build_suffix            = module.infra.build_suffix
  aws_region              = module.infra.aws_region
  cluster_name            = module.eks_cluster.cluster_name
  cluster_endpoint        = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate  = module.eks_cluster.cluster_ca_certificate
}
module "policy" {
    source = "./"
  
    # Pass outputs from the infra and eks-cluster modules as input variables
    project_prefix          = module.infra.project_prefix
    build_suffix            = module.infra.build_suffix
    aws_region              = module.infra.aws_region
    cluster_name            = module.eks_cluster.cluster_name
    cluster_endpoint        = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate  = module.eks_cluster.cluster_ca_certificate
  }