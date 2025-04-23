locals {
  build_suffix            = data.terraform_remote_state.infra.outputs.build_suffix
  host                   = data.terraform_remote_state.aks.outputs.aks_host
  cluster_ca_certificate = data.terraform_remote_state.aks.outputs.cluster_ca_certificate
  cluster_name           = data.terraform_remote_state.aks.outputs.cluster_name
  cluster_id           = data.terraform_remote_state.aks.outputs.cluster_id
  token           = data.terraform_remote_state.aks.outputs.token
}