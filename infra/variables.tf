# Variables.tf
variable "project_prefix" {
  type        = string
#  default     = "demo"
  description = "This value is inserted at the beginning of each AWS object (alpha-numeric, no special character)"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in format owner/repo"
  default     = "akananth/nginx_automation_examples"
}

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}
variable "resource_owner" {
  type        = string
  description = "owner of the deployment, for tagging purposes"
  default     = "myName"
}

variable "tf_state_bucket" {
  type        = string
  description = "S3 bucket for Terraform state"
  default     = "akash-terraform-state-bucket"
}

variable "create_role" {
  type        = bool
  description = "Whether to create the IAM role"
  default     = true
}

variable "create_policy" {
  type        = bool
  description = "Whether to create the IAM policy"
  default     = true
}

variable cidr {
  description = "the CIDR block for the Virtual Private Cloud (VPC) of the deployment"
  default = "10.0.0.0/16"
  type    = string
  validation {
    condition = can(regex("^([0-9]{1,3}.){3}[0-9]{1,3}($|/(16|24))$",var.cidr))
    error_message = "The value must conform to a CIDR block format."
  }
}
variable "azs" {
  description = "Availability Zones"
  type        = list
}
variable "create_nat_gateway" {
  type        = bool
  default     = false
  description = "Set to true if a NGW is needed"
}
variable "admin_src_addr" {
  type        = string
  description = "Allowed Admin source IP prefix"
  default     = "0.0.0.0/0"
}
variable "mgmt_address_prefixes" {
  type        = list(any)
  default     = ["10.1.1.0/24", "10.1.100.0/24"]
  description = "Management subnet address prefixes"
}
variable "ext_address_prefixes" {
  type        = list(any)
  default     = ["10.1.10.0/24", "10.1.110.0/24"]
  description = "External subnet address prefixes"
}
variable "int_address_prefixes" {
  type        = list(any)
  default     = ["10.1.20.0/24", "10.1.120.0/24"]
  description = "Internal subnet address prefixes"
}
variable "nap" {
  type = bool
}
variable "nic" {
  type = bool
}
variable "create_dynamodb_table" {
  description = "Whether to create the DynamoDB table for Terraform state locking."
  type        = bool
  default     = true
}

variable "create_s3_bucket" {
  description = "Whether to create the S3 bucket for Terraform state."
  type        = bool
  default     = true
}

variable "create_iam_role" {
  description = "Whether to create the IAM role for Terraform CI/CD."
  type        = bool
  default     = true
}

variable "create_iam_policy" {
  description = "Whether to create the IAM policy for Terraform state access."
  type        = bool
  default     = true
}

