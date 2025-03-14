# pv.tf
resource "kubernetes_persistent_volume" "policy_volume" {
  metadata {
    name = "policy-volume"
  }
  spec {
    capacity = {
      storage = "2Gi"  # Adjust the size as needed
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"  
    storage_class_name = "ebs-sc"  # Must match the PVC's storage class
    persistent_volume_source {
      host_path {
        path = var.workspace_path  # Use the variable here
      }
    }
  }
}