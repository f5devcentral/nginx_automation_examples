resource "kubernetes_job" "copy_policy" {
  metadata {
    name      = "copy-policy"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }
  spec {
    template {
      metadata {
        labels = {
          app = "copy-policy"
        }
      }
      spec {
        container {
          name  = "copy-policy"
          image = "busybox"  # Use a lightweight image
          command = ["sh", "-c", "cp /policy/compiled_policy.tgz /mnt/policy/compiled_policy.tgz"]
          volume_mount {
            name       = "policy-volume"
            mount_path = "/mnt/policy"
          }
        }
        volume {
          name = "policy-volume"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.policy_claim.metadata[0].name
          }
        }
        restart_policy = "Never"
      }
    }
  }

  depends_on = [helm_release.nginx-plus-ingress]  # Depend on the Helm release
}
