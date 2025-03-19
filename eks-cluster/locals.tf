locals {
  project_prefix          = data.terraform_remote_state.infra.outputs.project_prefix
  resource_owner          = data.terraform_remote_state.infra.outputs.resource_owner
  build_suffix            = data.terraform_remote_state.infra.outputs.build_suffix
  aws_region              = data.terraform_remote_state.infra.outputs.aws_region
  azs                     = data.terraform_remote_state.infra.outputs.azs
  vpc_id                  = data.terraform_remote_state.infra.outputs.vpc_id
  vpc_main_route_table_id = data.terraform_remote_state.infra.outputs.vpc_main_route_table_id
  public_subnet_ids       = data.terraform_remote_state.infra.outputs.public_subnet_ids
  eks_cidr                = data.terraform_remote_state.infra.outputs.eks_cidr[0] # Use the first CIDR block if eks_cidr is a list
  internal_sg_id          = data.terraform_remote_state.infra.outputs.internal_sg_id
  cluster_name            = format("%s-eks-cluster-%s", local.project_prefix, local.build_suffix)
}