
provider "kubectl" {
  # Configure your Kubernetes cluster access
  # Example configurations:
  # config_path = "~/.kube/config"
  # host                   = module.eks.cluster_endpoint
  # cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  # token                  = data.aws_eks_cluster_auth.cluster.token
}

data "http" "nginx_crds" {
  url = "https://raw.githubusercontent.com/nginx/kubernetes-ingress/v4.0.1/deploy/crds.yaml"
}

resource "kubectl_manifest" "nginx_crds" {
  for_each   = { for idx, doc in split("---", data.http.nginx_crds.response_body) : idx => doc if doc != "" }
  yaml_body  = each.value
  apply_only = true

  # Wait 10 seconds between retries (total 5 attempts)
  retry {
    attempts = 5
    delay    = "10s"
  }
}
