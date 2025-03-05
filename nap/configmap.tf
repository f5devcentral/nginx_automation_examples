resource "kubernetes_config_map" "app_protect_bundles" {
  metadata {
    name      = "app-protect-bundles"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }

  binary_data = {
    "compiled_policy.tgz" = var.compiled_policy_base64
  }
}
