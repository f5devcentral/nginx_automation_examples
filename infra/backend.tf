terraform {
  backend "s3" {
    bucket = "akash-terraform-state-bucket"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}
