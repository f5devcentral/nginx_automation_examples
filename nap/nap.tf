resource "helm_release" "nginx-plus-ingress" {
  count = 1
    name = format("%s-nap-%s", local.project_prefix, local.build_suffix)
    repository = "https://helm.nginx.com/stable"
    chart = "nginx-ingress"
    #version = "0.16.2"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
    values = [file("./charts/nginx-app-protect/values.yaml")]
    timeout    = 600  # 10 minutes timeout

    depends_on = [
      kubernetes_secret.docker-registry
    ]
}
