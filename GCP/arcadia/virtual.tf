resource "kubernetes_manifest" "arcadia_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "arcadia-virtualserver"
      namespace = "default"
    }
    spec = {
      host = data.terraform_remote_state.nap.outputs.external_name
      
      # Reference the WAF policy
      policies = [
        {
          name      = "waf-policy"  # Name of the WAF policy
          namespace = "default"     # Namespace where the WAF policy is deployed
        }
      ]

      upstreams = [
        {
          name    = "main-upstream"
          service = kubernetes_service.main.metadata[0].name
          port    = 80
        },
        {
          name    = "backend-upstream"
          service = kubernetes_service.backend.metadata[0].name
          port    = 80
        },
        {
          name    = "app2-upstream"
          service = kubernetes_service.app_2.metadata[0].name
          port    = 80
        },
        {
          name    = "app3-upstream"
          service = kubernetes_service.app_3.metadata[0].name
          port    = 80
        }
      ]
      routes = [
        {
          path = "/"
          action = {
            pass = "main-upstream"
          }
        },
        {
          path = "/files"
          action = {
            pass = "backend-upstream"
          }
        },
        {
          path = "/api"
          action = {
            pass = "app2-upstream"
          }
        },
        {
          path = "/app3"
          action = {
            pass = "app3-upstream"
          }
        }
      ]
    }
  }
}
