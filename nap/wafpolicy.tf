resource "kubernetes_manifest" "waf_policy" {
  depends_on = [null_resource.compile_policy]

  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "Policy"
    metadata = {
      name = "waf-policy"
    }
    spec = {
      waf = {
        enable    = true
        apBundle  = "${path.module}/compiled_policy.tgz"
      }
    }
  }
}

