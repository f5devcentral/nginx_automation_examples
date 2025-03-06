resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "kubernetes_persistent_volume" "policy_volume" {
  metadata {
    name = "policy-volume"
  }
  spec {
    capacity = {
      storage = "1Gi"  # Adjust the size as needed
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/mnt/data"  # Host path on the node
      }
    }
  }
}

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

  depends_on = [kubernetes_namespace.nginx-ingress]
}
