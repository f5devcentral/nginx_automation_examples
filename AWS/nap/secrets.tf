resource "kubernetes_secret" "nginx_license" {
  metadata {
    name      = "license-token"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }

  data = {
    "license.jwt" = var.nginx_jwt
  }

  type = "nginx.com/license"
}

resource "kubernetes_secret" "docker-registry" {
  metadata {
    name      = "regcred"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.nginx_registry}" = {
          "username" = var.nginx_jwt,  # Use the JWT token as the username
          "password" = "none",  # Set password to "none"
          "auth"     = base64encode("${var.nginx_jwt}:none")  # Encode "<jwt-token>:none"
        }
      }
    })
  }
}