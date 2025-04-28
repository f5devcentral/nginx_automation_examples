locals {
  project_id      = data.terraform_remote_state.infra.outputs.gcp_project_id
  region          = data.terraform_remote_state.infra.outputs.gcp_region
  network_name    = data.terraform_remote_state.infra.outputs.vpc_name
  subnet_name     = data.terraform_remote_state.infra.outputs.vpc_subnet
  project_prefix  = data.terraform_remote_state.infra.outputs.project_prefix
}
