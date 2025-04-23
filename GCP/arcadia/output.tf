output "external_name" {
  description = "The external hostname of NGINX Ingress from NAP"
  value = data.terraform_remote_state.nap.outputs.external_name
  sensitive = true
}
