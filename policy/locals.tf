locals {
  project_prefix          = data.terraform_remote_state.infra.outputs.project_prefix
  build_suffix            = data.terraform_remote_state.infra.outputs.build_suffix
  aws_region              = data.terraform_remote_state.infra.outputs.aws_region
  host                    = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate  = data.terraform_remote_state.eks.outputs.kubeconfig-certificate-authority-data
  cluster_name            = data.terraform_remote_state.eks.outputs.cluster_name
  app                     = format("%s-nap-%s", local.project_prefix, local.build_suffix)
}