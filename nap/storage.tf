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
