# Output the external name of the NGINX service (e.g., LoadBalancer hostname)
output "external_name" {
  description = "The external hostname of the NGINX service"
  value       = try(data.kubernetes_service_v1.nginx-service.status[0].load_balancer[0].ingress[0].hostname, null)
}

# Output the external port of the NGINX service
output "external_port" {
  description = "The external port of the NGINX service"
  value       = try(data.kubernetes_service_v1.nginx-service.spec[0].port[0].port, null)
}

# Output the origin source of the NAP deployment
output "origin_source" {
  description = "The origin source of the NAP deployment"
  value       = "nap"
}

# Output the name of the NAP deployment
output "nap_deployment_name" {
  description = "The name of the NAP deployment"
  value       = try(helm_release.nginx-plus-ingress.name, null)
  sensitive   = true
}

# Output the name of the NAP application
output "app_name" {
  description = "The name of the NAP application"
  value       = local.app
}

# Output the name of the EKS cluster
output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = local.cluster_name
}

# Output the endpoint of the EKS cluster
output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = local.host
}