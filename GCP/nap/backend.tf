terraform {
  backend "gcs" {
    prefix         = "nap/terraform.tfstate"
  }
}
