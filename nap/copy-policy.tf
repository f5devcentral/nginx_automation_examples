resource "null_resource" "install_kubectl" {
  provisioner "local-exec" {
    command = <<EOT
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      chmod +x kubectl
      sudo mv kubectl /usr/local/bin/
      export PATH=$PATH:/usr/local/bin
    EOT
  }
}

resource "null_resource" "copy_compiled_policy" {
  depends_on = [
    null_resource.install_kubectl,
    helm_release.nginx-plus-ingress # Ensures Helm release from nap.tf is completed
  ]

  provisioner "local-exec" {
    command = <<EOT
      # Wait for NGINX Ingress pods to be ready
      kubectl wait --namespace nginx-ingress \
        --for=condition=Ready pod \
        -l app.kubernetes.io/name=nginx-ingress \
        --timeout=300s

      # Get the first running NGINX Ingress pod name
      POD_NAME=$(kubectl get pods -n nginx-ingress -l app.kubernetes.io/name=nginx-ingress -o jsonpath="{.items[0].metadata.name}")

      # Copy the compiled policy to the NGINX Ingress pod
      kubectl cp ./charts/compiled_policy.tgz nginx-ingress/$POD_NAME:/etc/app_protect/bundles/
    EOT
  }
}

