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

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "Availability Zones"
  type        = list
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS Session Token"
  type        = string
  sensitive   = true
}

# SSH Key (for potential SSH-based configurations)
variable "ssh_key" {
  type        = string
  description = "Unneeded for NGINX App Protect, only used for TF Cloud variable warnings"
}

variable "nginx_pod_name" {
  description = "Name of the NGINX Ingress Controller pod"
  type        = string
}