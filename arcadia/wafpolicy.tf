resource "kubernetes_manifest" "waf_policy" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "Policy"
    metadata = {
      name      = "waf-policy"
      namespace = "default"  # Replace with your desired namespace
    }
    spec = {
      waf = {
        enable   = true
        apBundle = "compiled_policy.tgz"
      }
    }
  }
}
