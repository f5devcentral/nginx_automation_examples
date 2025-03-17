# Terraform Cloud Organization
variable "tf_cloud_organization" {
  type        = string
  description = "Terraform Cloud Organization (set in GitHub secrets)"
}

# NGINX Configuration
variable "nginx_registry" {
  type        = string
  description = "NGINX Docker registry"
  default     = "private-registry.nginx.com"
}

variable "nginx_jwt" {
  type        = string
  description = "JWT for pulling NGINX image"
}

variable "nginx_pwd" {
  type        = string
  description = "Password for NGINX (if required)"
  default     = "none"
}
variable "workspace_path" {
  type    = string
  default = ""  # Provide a default value or leave it empty
}

# SSH Key (for potential SSH-based configurations)
variable "ssh_key" {
  type        = string
  description = "Unneeded for NGINX App Protect, only used for TF Cloud variable warnings"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
