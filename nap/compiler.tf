provider "local" {}

# Create the certificates directory relative to the module
resource "null_resource" "create_directory" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/certs.d/private-registry.nginx.com"
  }
}

# Create NGINX repository certificate file
resource "null_resource" "nginx_repo_crt" {
  depends_on = [null_resource.create_directory]

  provisioner "local-exec" {
    command = <<EOT
      echo '${var.nginx_repo_crt}' > ${path.module}/certs.d/private-registry.nginx.com/client.cert
    EOT
  }
}

# Create NGINX repository key file
resource "null_resource" "nginx_repo_key" {
  depends_on = [null_resource.create_directory]

  provisioner "local-exec" {
    command = <<EOT
      echo '${var.nginx_repo_key}' > ${path.module}/certs.d/private-registry.nginx.com/client.key
    EOT
  }
}

# Read the policy JSON file
data "local_file" "policy_json" {
  filename = "${path.module}/charts/policy.json"
}

# Build the Docker image using BuildKit
resource "null_resource" "docker_build" {
  depends_on = [
    null_resource.nginx_repo_crt,
    null_resource.nginx_repo_key,
  ]

  provisioner "local-exec" {
    command = <<EOT
      docker build --no-cache \
      --secret id=nginx-crt,src=${path.module}/certs.d/private-registry.nginx.com/client.cert \
      --secret id=nginx-key,src=${path.module}/certs.d/private-registry.nginx.com/client.key \
      -t waf-compiler-5.5.0:custom ${path.module}/charts
    EOT
  }
}

# Compile the policy using Docker
resource "null_resource" "compile_policy" {
  depends_on = [
    null_resource.docker_build,
    data.local_file.policy_json
  ]

  provisioner "local-exec" {
    command = <<EOT
      docker run --rm \
      -v ${path.module}:${path.module} \
      waf-compiler-5.5.0:custom \
      -p ${path.module}/charts/policy.json -o ${path.module}/compiled_policy.tgz
    EOT
  }
}
