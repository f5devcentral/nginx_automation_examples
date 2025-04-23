resource "helm_release" "grafana" {
  name = format("%s-gfa-%s", local.project_prefix, local.build_suffix)
  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"
  version = "6.50.7"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  values = [file("./charts/grafana/values.yaml")]
}
