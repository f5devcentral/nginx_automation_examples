# policy/main.tf
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}

provider "kubernetes" {
  host                   = local.host
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.auth.token
}

provider "helm" {
  kubernetes {
    host                   = local.host
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.auth.token
  }
}

provider "kubectl" {
  host                   = local.host
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.auth.token
  load_config_file       = false
}

resource "null_resource" "copy_compiled_policy" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl cp ${path.module}/compiled_policy.tgz ${var.nginx_pod_name}:/etc/app_protect/bundles/compiled_policy.tgz -n nginx-ingress -c nginx-plus-ingress
    EOT
  }
}