resource "helm_release" "nginx-plus-ingress" {
  name       = format("%s-nap-%s", local.project_prefix, local.build_suffix)
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  version = "2.0.1" # Uncomment and specify a version for stability
  namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  values     = [file("./charts/nginx-app-protect/values.yaml")]
  timeout    = 600 # Timeout in seconds (10 minutes)
  depends_on = [
    kubernetes_secret.docker-registry
  ]
}

