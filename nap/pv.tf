# Create the PersistentVolume (PV)
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
        path = "${{ github.workspace }}/policy"  # Use the path where the file is generated
      }
    }
  }
}