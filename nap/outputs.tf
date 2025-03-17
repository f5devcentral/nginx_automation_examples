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
output "aws_access_key_id" {
  description = "AWS Access Key ID"
  value       = var.aws_access_key_id  # or the actual resource/expression
  sensitive   = true
}

output "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  value       = var.aws_secret_access_key
  sensitive   = true
}

output "aws_session_token" {
  description = "AWS Session Token"
  value       = var.aws_session_token
  sensitive   = true
}


