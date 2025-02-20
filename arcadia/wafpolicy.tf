resource "kubectl_manifest" "waf_policy" {
  yaml_body = <<YAML
apiVersion: k8s.nginx.org/v1
kind: Policy
metadata:
  name: waf-policy
spec:
  waf:
    enable: true
    apBundle: compiled_policy.tgz
YAML
}
