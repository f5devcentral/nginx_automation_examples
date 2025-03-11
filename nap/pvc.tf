resource "kubernetes_persistent_volume_claim" "policy_claim" {
  metadata {
    name      = "policy-claim"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"  # Adjust the size as needed
      }
    }
    volume_name = kubernetes_persistent_volume.policy_volume.metadata[0].name
  }

  depends_on = [kubernetes_namespace.nginx-ingress]  # Depend only on the namespace
}