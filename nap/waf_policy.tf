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
    command = <<EOT
      POD_NAME=$(kubectl get pods -n nginx-ingress -l app.kubernetes.io/name=nginx-ingress -o jsonpath='{.items[0].metadata.name}')
      kubectl cp ${path.module}/compiled_policy.tgz nginx-ingress/$POD_NAME:/etc/app_protect/bundles/compiled_policy.tgz
    EOT
  }
}

