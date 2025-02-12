resource "helm_release" "prometheus" {
  name = format("%s-pro-%s", lower(local.custom_prefix), lower(local.build_suffix))
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  values = [file("./charts/prometheus/values.yaml")]
}
