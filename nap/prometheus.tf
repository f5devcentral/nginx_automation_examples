resource "helm_release" "prometheus" {
  name       = format("%s-pro-%s", local.project_prefix, local.build_suffix)
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  values     = [file("./charts/prometheus/values.yaml")]
  timeout    = 600  # 10 minutes timeout
}

