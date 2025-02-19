resource "nginx_virtual_server" "arcadia_virtual_server" {
  metadata {
    name = "arcadia-virtual-server"
  }

  spec {
    virtual_server {
      host = try(data.tfe_outputs.nap[0].values.external_name, data.tfe_outputs.nic[0].values.external_name)

      # Add the WAF policy
      policies {
        name = "waf-policy"
      }

      # Define the routes
      route {
        path = "/"
        backend {
          service {
            name = kubernetes_service.main.metadata.0.name
            port {
              number = 80
            }
          }
        }
      }

      route {
        path = "/files"
        backend {
          service {
            name = kubernetes_service.backend.metadata.0.name
            port {
              number = 80
            }
          }
        }
      }

      route {
        path = "/api"
        backend {
          service {
            name = kubernetes_service.app_2.metadata.0.name
            port {
              number = 80
            }
          }
        }
      }

      route {
        path = "/app3"
        backend {
          service {
            name = kubernetes_service.app_3.metadata.0.name
            port {
              number = 80
            }
          }
        }
      }
    }
  }
}
