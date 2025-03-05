resource "kubernetes_config_map" "app_protect_bundles" {
  metadata {
    name      = "app-protect-bundles"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }

  binary_data = {
    "compiled_policy.tgz" = filebase64("${path.module}/policy/compiled_policy.tgz")
  }
}
