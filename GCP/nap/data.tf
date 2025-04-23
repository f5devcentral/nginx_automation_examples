data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = var.GCP_BUCKET_NAME       # Your S3 bucket name
    prefix    = "infra/terraform.tfstate"       # Path to infra's state file
  }
}

# Read eks state from S3
data "terraform_remote_state" "gke" {
  backend = "gcs"
  config = {
    bucket =  var.GCP_BUCKET_NAME        # Your S3 bucket name
    prefix    = "gke/terraform.tfstate" # Path to EKS state file
  }
}

data "kubernetes_service_v1" "nginx-service" {
  metadata {
    name      = try(format("%s-%s-controller", helm_release.nginx-plus-ingress.name, helm_release.nginx-plus-ingress.chart))
    namespace = try(helm_release.nginx-plus-ingress.namespace)
  }
}
