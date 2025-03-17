# eks-cluster/locals.tf
locals {
  project_prefix          = var.project_prefix
  resource_owner          = var.resource_owner
  build_suffix            = var.build_suffix
  aws_region              = var.aws_region
  azs                     = var.azs
  vpc_id                  = var.vpc_id
  vpc_main_route_table_id = var.vpc_main_route_table_id
  public_subnet_ids       = var.public_subnet_ids
  eks_cidr                = var.eks_cidr
  internal_sg_id          = var.internal_sg_id
  cluster_name            = format("%s-eks-cluster-%s", local.project_prefix, local.build_suffix)
}