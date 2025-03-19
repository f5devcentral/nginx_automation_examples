terraform {
  backend "s3" {
    # These values will be overridden by the -backend-config flags
    bucket         = "dummy"
    key            = "dummy"
    region         = "dummy"
    dynamodb_table = "dummy"
  }
}