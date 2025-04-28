locals {
  build_suffix        = data.terraform_remote_state.infra.outputs.build_suffix
  vnet_name           = data.terraform_remote_state.infra.outputs.vnet_name
  subnet_name         = data.terraform_remote_state.infra.outputs.subnet_name
  vnet_id             = data.terraform_remote_state.infra.outputs.vnet_id
  subnet_id           = data.terraform_remote_state.infra.outputs.subnet_id
}