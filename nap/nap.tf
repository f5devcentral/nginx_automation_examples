resource "helm_release" "nginx-plus-ingress" {
<<<<<<< HEAD
  name       = format("%s-nap-%s", local.project_prefix, local.build_suffix)
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  # version = "0.16.2" # Uncomment and specify a version for stability
  namespace  = kubernetes_namespace.nginx-ingress.metadata.name
  values     = [file("./charts/nginx-app-protect/values.yaml")]
=======
    name = format("%s-nap-%s", local.project_prefix, local.build_suffix)
    repository = "https://helm.nginx.com/stable"
    chart = "nginx-ingress"
    #version = "0.16.2"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
    values = [file("./charts/nginx-app-protect/values.yaml")]
    timeout    = 600  # 10 minutes timeout
>>>>>>> f9e73d94ace0f15d13370687bc4cb86f1f26a2cb

  depends_on = [
    kubernetes_secret.docker-registry
  ]
}

