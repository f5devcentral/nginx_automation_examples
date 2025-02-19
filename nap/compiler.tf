provider "local" {}

# Change ownership of /etc/docker/ to the current user (if necessary)
resource "null_resource" "change_ownership" {
  provisioner "local-exec" {
    command = "sudo chown -R $(whoami):$(whoami) /etc/docker/"
  }
}

# Create the required directory for certificates
resource "null_resource" "create_directory" {
  depends_on = [null_resource.change_ownership]

  provisioner "local-exec" {
    command = "sudo mkdir -p /etc/docker/certs.d/private-registry.nginx.com"
  }
}

# Create the local file for the NGINX repository certificate
resource "local_file" "nginx_repo_crt" {
  content  = var.nginx_repo_crt
  filename = "/etc/docker/certs.d/private-registry.nginx.com/client.cert"
}

# Create the local file for the NGINX repository key
resource "local_file" "nginx_repo_key" {
  content  = var.nginx_repo_key
  filename = "/etc/docker/certs.d/private-registry.nginx.com/client.key"
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
    local_file.nginx_repo_crt,
    local_file.nginx_repo_key,
    null_resource.create_directory
  ]

  provisioner "local-exec" {
    command = <<EOT
      sudo cp /etc/docker/certs.d/private-registry.nginx.com/client.cert /home/ubuntu/nginx-repo.crt
      sudo cp /etc/docker/certs.d/private-registry.nginx.com/client.key /home/ubuntu/nginx-repo.key

      sudo docker build --no-cache \
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

