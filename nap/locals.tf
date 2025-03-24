locals {
  # Fetch project_prefix and build_suffix from the infra state
  project_prefix = data.terraform_remote_state.infra.outputs.project_prefix
  build_suffix   = data.terraform_remote_state.infra.outputs.build_suffix

  # Fetch EKS cluster details from the eks-cluster state
  cluster_name            = data.terraform_remote_state.eks.outputs.cluster_name
  aws_region              = data.terraform_remote_state.eks.outputs.aws_region
  host                    = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate  = data.terraform_remote_state.eks.outputs.kubeconfig-certificate-authority-data

  # Define the app name using project_prefix and build_suffix
  app = format("%s-nap-%s", local.project_prefix, local.build_suffix)
}