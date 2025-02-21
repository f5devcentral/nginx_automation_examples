resource "kubectl_manifest" "nginx_crds" {
  yaml_body = file("${path.module}/crds.yaml")
}

resource "null_resource" "download_crds" {
  provisioner "local-exec" {
    command = "curl -o ${path.module}/crds.yaml https://raw.githubusercontent.com/nginx/kubernetes-ingress/v4.0.1/deploy/crds.yaml"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "kubectl_manifest" "apply_crds" {
  depends_on = [null_resource.download_crds]

  yaml_body = file("${path.module}/crds.yaml")
}

