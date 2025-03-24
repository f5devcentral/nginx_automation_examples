
resource "kubernetes_service_account" "ebs_csi_controller" {
  depends_on = [
    data.terraform_remote_state.eks.outputs.cluster_endpoint,
    data.terraform_remote_state.eks.outputs.oidc_provider_arn
  ]
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks.outputs.ebs_csi_driver_role_arn
    }
  }
}

resource "kubernetes_storage_class_v1" "aws_csi" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  parameters = {
    type = "gp3"
    fsType = "ext4"
  }
  allow_volume_expansion = true
  volume_binding_mode = "WaitForFirstConsumer"
}
