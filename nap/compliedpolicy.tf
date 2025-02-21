resource "null_resource" "copy_compiled_policy" {
  provisioner "local-exec" {
    command = <<EOT
      INGRESS_POD=$(kubectl get pods -n nginx-ingress -l app.kubernetes.io/name=nginx-ingress -o jsonpath="{.items[0].metadata.name}")
      kubectl cp $(pwd)/charts/compiled_policy.tgz nginx-ingress/$INGRESS_POD:/etc/app_protect/bundles/compiled_policy.tgz -n nginx-ingress
    EOT
  }
}
