output "external_name" {
    value = try(tolist(data.kubernetes_service_v1.nginx-service.status.load_balancer.ingress)[0].hostname, null)
}

output "external_port" {
    value = try(tolist(data.kubernetes_service_v1.nginx-service.spec.port)[0].port, null)
}

output "origin_source" {
    value = "nap"
}

output "nap_deployment_name" {
    value = try(helm_release.nginx-plus-ingress.name, null)
    sensitive = true
}

