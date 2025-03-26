locals {
  project_prefix          = data.terraform_remote_state.infra.outputs.project_prefix
  aws_region             = data.terraform_remote_state.infra.outputs.aws_region
  external_name          = try(data.terraform_remote_state.nap.outputs.external_name)
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = data.terraform_remote_state.eks.outputs.kubeconfig-certificate-authority-data
  cluster_name           = data.terraform_remote_state.eks.outputs.cluster_name
}
