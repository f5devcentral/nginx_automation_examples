variable "tf_state_bucket" {
  type        = string
  description = "S3 bucket for Terraform state"
  default     = "akash-terraform-state-bucket"
}
variable "create_iam_resources" {
  description = "Whether to create IAM resources (role and policy)."
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}
