variable "policy_content" {
  description = "Content of the App Protect policy JSON"
  type        = string
  default     = file("${path.module}/charts/policy.json")
}

provider "local" {
  # This provider is used to manage local files
}

resource "null_resource" "create_directory" {
  provisioner "local-exec" {
    command = "mkdir -p /etc/docker/certs.d/private-registry.nginx.com"
  }
}

resource "local_file" "nginx_repo_crt" {
  content  = var.nginx_repo_crt
  filename = "/etc/docker/certs.d/private-registry.nginx.com/client.cert"
}

resource "local_file" "nginx_repo_key" {
  content  = var.nginx_repo_key
  filename = "/etc/docker/certs.d/private-registry.nginx.com/client.key"
}

resource "local_file" "app_protect_policy" {
  content  = var.policy_content
  filename = "${path.module}/charts/policy.json"
}

resource "null_resource" "docker_build" {
  depends_on = [
    local_file.nginx_repo_crt,
    local_file.nginx_repo_key,
    null_resource.create_directory
  ]

  provisioner "local-exec" {
    command = <<EOT
      # Copy the certificates to /home/ubuntu
      cp /etc/docker/certs.d/private-registry.nginx.com/client.cert /home/ubuntu/nginx-repo.crt
      cp /etc/docker/certs.d/private-registry.nginx.com/client.key /home/ubuntu/nginx-repo.key

      # Run the Docker command to build the image
      sudo docker build --no-cache \
      --secret id=nginx-crt,src=/home/ubuntu/nginx-repo.crt \
      --secret id=nginx-key,src=/home/ubuntu/nginx-repo.key \
      -t waf-compiler-5.2.0:custom ./charts/nginx-app-protect
    EOT
  }
}

resource "null_resource" "compile_policy" {
  depends_on = [null_resource.docker_build, local_file.app_protect_policy]

  provisioner "local-exec" {
    command = <<EOT
      # Run the Docker command to compile the policy and store it in the current directory
      docker run --rm \
      -v $(pwd):$(pwd) \
      waf-compiler-5.5.0:custom \
      -p $(pwd)./charts/policy.json -o $(pwd)/compiled_policy.tgz
    EOT
  }
}
