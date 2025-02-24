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
