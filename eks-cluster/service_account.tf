resource "kubectl_manifest" "ebs_csi_sa" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ebs-csi-controller-sa
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.workernodes.arn}
YAML
}

