resource "kubernetes_config_map" "policy" {
  metadata {
    name      = "app-protect-bundles"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }

   data = {
    "compiled_policy.tgz" = "${filebase64("${path.root}/policy/compiled_policy.base64")}"

  }
}
