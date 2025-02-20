provider "local" {}

# Modify permissions for the /home/ubuntu directory
resource "null_resource" "modify_permissions" {
  provisioner "local-exec" {
    command = "chown -R $(whoami) /home/ubuntu && chmod -R 755 /home/ubuntu"
  }
}

# Create the required directory for certificates
resource "null_resource" "create_directory" {
  depends_on = [null_resource.modify_permissions]

  provisioner "local-exec" {
    command = "mkdir -p /home/ubuntu/certs.d/private-registry.nginx.com"
  }
}

# Create the local file for the NGINX repository certificate
resource "null_resource" "nginx_repo_crt" {
  depends_on = [null_resource.create_directory]

  provisioner "local-exec" {
    command = "echo '${var.nginx_repo_crt}' | tee /home/ubuntu/certs.d/private-registry.nginx.com/client.cert"
  }
}

# Create the local file for the NGINX repository key
resource "null_resource" "nginx_repo_key" {
  depends_on = [null_resource.create_directory]

  provisioner "local-exec" {
    command = "echo '${var.nginx_repo_key}' | tee /home/ubuntu/certs.d/private-registry.nginx.com/client.key"
  }
}

# Read the policy JSON file
data "local_file" "policy_json" {
  filename = "${path.module}/charts/policy.json"  # Ensure this path is correct
}

# Create the App Protect policy file
resource "local_file" "app_protect_policy" {
  content  = data.local_file.policy_json.content
  filename = "${path.module}/charts/policy.json"  # This line might be unnecessary if it's just reading
}

# Build the Docker image
resource "null_resource" "docker_build" {
  depends_on = [
    null_resource.nginx_repo_crt,
    null_resource.nginx_repo_key,
    null_resource.create_directory
  ]

  provisioner "local-exec" {
    command = <<EOT
      cp /home/ubuntu/certs.d/private-registry.nginx.com/client.cert /home/ubuntu/nginx-repo.crt
      cp /home/ubuntu/certs.d/private-registry.nginx.com/client.key /home/ubuntu/nginx-repo.key

      docker build --no-cache \
      --secret id=nginx-crt,src=/home/ubuntu/nginx-repo.crt \
      --secret id=nginx-key,src=/home/ubuntu/nginx-repo.key \
      -t waf-compiler-5.5.0:custom ${path.module}/charts
    EOT
  }
}

# Compile the policy
resource "null_resource" "compile_policy" {
  depends_on = [
    null_resource.docker_build,
    local_file.app_protect_policy
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

