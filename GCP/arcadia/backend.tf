terraform {
  backend "gcs" {
    prefix         = "arcadia/terraform.tfstate"
  }
}
