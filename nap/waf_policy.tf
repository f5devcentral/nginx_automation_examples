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
        enable   = true
        apBundle = "compiled_policy.tgz"
      }
    }
  }
}

resource "null_resource" "copy_policy_bundle" {
  depends_on = [null_resource.compile_policy]

  provisioner "local-exec" {
    command = "cp ${path.module}/compiled_policy.tgz /etc/app_protect/bundles/"
  }
}

