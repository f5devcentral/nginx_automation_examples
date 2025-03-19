# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {
    bucket         = "{{ .Bucket }}"
    key            = "{{ .Key }}"
    region         = "{{ .Region }}"
    dynamodb_table = "{{ .DynamoDBTable }}"
  }
}