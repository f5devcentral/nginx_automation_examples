resource "kubectl_manifest" "virtual_server" {
  yaml_body = <<YAML
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: arcadia-virtual-server
spec:
  host: "${local.external_name}"
  policies:
    - name: waf-policy
  upstreams:
    - name: main
      service: ${kubernetes_service.main.metadata.0.name}
      port: 80
    - name: backend
      service: ${kubernetes_service.backend.metadata.0.name}
      port: 80
    - name: app_2
      service: ${kubernetes_service.app_2.metadata.0.name}
      port: 80
    - name: app_3
      service: ${kubernetes_service.app_3.metadata.0.name}
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
        pass: app_2
    - path: /app3
      action:
        pass: app_3
YAML
}

