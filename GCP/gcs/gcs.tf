resource "google_storage_bucket" "bucket" {
  name     = var.GCP_BUCKET_NAME
  location = var.GCP_REGION
}


