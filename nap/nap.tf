resource "helm_release" "nginx-plus-ingress" {
  name       = format("%s-nap-%s", local.project_prefix, local.build_suffix)
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  # version = "0.16.2" # Uncomment and specify a version for stability
  namespace  = kubernetes_namespace.nginx-ingress.metadata.name
  values     = [file("./charts/nginx-app-protect/values.yaml")]

  depends_on = [
    kubernetes_secret.docker-registry
  ]
}

