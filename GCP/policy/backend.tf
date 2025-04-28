terraform {
  backend "gcs" {
    prefix         = "policy/terraform.tfstate"
  }
}
