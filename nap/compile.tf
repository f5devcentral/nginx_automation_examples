resource "null_resource" "copy_compiled_policy" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl cp ${path.module}/compiled_policy.tgz ${var.nginx_pod_name}:/etc/app_protect/bundles/compiled_policy.tgz -n nginx-ingress -c nginx-plus-ingress
    EOT
  }

  depends_on = [helm_release.nginx-plus-ingress]
}