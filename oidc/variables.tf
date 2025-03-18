# oidc/variables.tf
variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-1"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in format owner/repo"
  default     = "akananth/nginx_automation_examples"
}

variable "tf_state_bucket" {
  type        = string
  description = "S3 bucket for Terraform state"
  default     = "akash-terraform-state-bucket"
}