# Read infra state from gcs
data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket =  var.GCP_BUCKET_NAME                # Your gcs bucket namee
    prefix    = "infra/terraform.tfstate"           # Path to infra state file
  }
}

# Read gke state from gcs
data "terraform_remote_state" "gke" {
  backend = "gcs"
  config = {
    bucket =  var.GCP_BUCKET_NAME                 # Your gcs bucket name
    prefix    = "gke/terraform.tfstate"              # Path to GKE state file
  }
}

# Read nap state from gcs
data "terraform_remote_state" "nap" {
  backend = "gcs"
  config = {
    bucket =  var.GCP_BUCKET_NAME                 # Your gcs bucket name
    prefix    = "nap/terraform.tfstate"              # Path to NAP state file
  }
}