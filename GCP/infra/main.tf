provider "google" {
  credentials = var.GOOGLE_CREDENTIALS
  project     = var.GCP_PROJECT_ID
  region      = var.GCP_REGION
}
