# pvc.tf
resource "kubernetes_persistent_volume_claim" "policy_claim" {
  metadata {
    name      = "policy-claim"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]  # EBS supports ReadWriteOnce
    resources {
      requests = {
        storage = "1Gi"  # Adjust the size as needed
      }
    }
    storage_class_name = "ebs-sc"  # Use the storage class you defined
  }

  depends_on = [kubernetes_namespace.nginx-ingress]  # Ensure the namespace exists
}