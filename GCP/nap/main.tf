provider "google" {
    region                  = local.region
}

provider "kubernetes" {
  host                   = local.host
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
  token                  = local.cluster_token

  # Optional: Using exec for kubectl authentication
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gcloud"
    args = [
      "container", "clusters", "get-credentials",
      local.cluster_name,  # Assuming 'local.cluster_name' is set
      "--region", local.region  # Assuming 'local.cluster_region' is set
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = local.host
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
    token                  = local.cluster_token

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gcloud"
      args = [
        "container", "clusters", "get-credentials",
        local.cluster_name,  # Cluster name
        "--region", local.region  # Cluster region
      ]
    }
  }
}

provider "kubectl" {
    host                    = local.host
    cluster_ca_certificate  = base64decode(local.cluster_ca_certificate)
    token                   = local.cluster_token
    load_config_file        = false
    exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gcloud"
    args = [
      "container", "clusters", "get-credentials",
      local.cluster_name,  # Cluster name
      "--region", local.region  # Cluster region
    ]
  }
}