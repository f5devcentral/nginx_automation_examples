resource "kubectl_manifest" "virtual_server" {
  yaml_body = <<YAML
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: acradia-virtual-server
spec:
  host: "${local.external_name}"
  policies:
    - name: waf-policy
  upstreams:
    - name: main
      service: main
      port: 80
    - name: backend
      service: backend
      port: 80
    - name: app2  # Changed from app_2 to app2
      service: app2
      port: 80
    - name: app3  # Changed from app_3 to app3
      service: app3
      port: 80
  routes:
    - path: /
      action:
        pass: main
    - path: /files
      action:
        pass: backend
    - path: /api
      action:
        pass: app2  # Changed from app_2 to app2
    - path: /app3
      action:
        pass: app3  # Changed from app_3 to app3
YAML
}

