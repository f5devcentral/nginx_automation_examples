output "external_name" {
    value = try(data.kubernetes_service_v1.nginx-service.status.0.load_balancer.0.ingress.0.hostname, null)
}
output "external_port" {
    value = try(data.kubernetes_service_v1.nginx-service.spec.0.port.0.port, null)
}
output "origin_source" {
    value = "nap"
}
output "nap_deployment_name" {
    value = try(helm_release.nginx-plus-ingress.name, null)
    sensitive = true
}
output "copy_policy_complete" {
  description = "Indicates that the compiled policy has been copied"
  value       = null_resource.copy_compiled_policy.id
}


