resource "helm_release" "nginx-plus-ingress" {
  name       = format("%s-nap-%s", local.project_prefix, local.build_suffix)
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  version    = "2.0.1"
  namespace  = kubernetes_namespace.nginx-ingress.metadata[0].name
  values     = [file("./charts/nginx-app-protect/values.yaml")]
  timeout    = 500

  depends_on = [
    kubernetes_secret.docker-registry,
    null_resource.nap_complete
  ]
}

resource "null_resource" "nap_complete" {
  triggers = {
    nap_complete = "true"
  }
}

resource "null_resource" "copy_compiled_policy" {
  depends_on = [
    helm_release.nginx-plus-ingress # Ensure this runs after the Helm release
  ]

  provisioner "local-exec" {
    command = <<EOT
      kubectl cp ${path.module}/nap/charts/compiled_policy.tgz nginx-ingress/${helm_release.nginx-plus-ingress.name}:/etc/app_protect/bundles/compiled_policy.tgz -n nginx-ingress
      kubectl exec -n nginx-ingress ${helm_release.nginx-plus-ingress.name} -- ls -lh /etc/app_protect/bundles/
    EOT
  }
}
