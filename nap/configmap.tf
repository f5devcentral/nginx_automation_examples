data "local_file" "compiled_policy" {
  filename = "${path.module}/compiled_policy_base64.txt"
}

resource "kubernetes_config_map" "policy" {
  metadata {
    name      = "app-protect-bundles"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }

  data = {
    "compiled_policy.tgz" = data.local_file.compiled_policy.content
  }
}