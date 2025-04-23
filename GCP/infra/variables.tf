variable "GCP_REGION" {
  description = "GCP region name"
  type        = string
}

variable "cidr" {
  description = "CIDR to create subnet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "GOOGLE_CREDENTIALS" {
  type    = string
}

variable "GCP_PROJECT_ID" {
  type    = string
}

# variable "service_account" {
#   type    = string
#   default = ""
# }

variable "project_prefix" {
  type        = string
  description = "This value is inserted at the beginning of each cloud object (alpha-numeric, no special character)"
}

