# NGINX Configuration
variable "nginx_registry" {
  type        = string
  description = "NGINX Docker registry"
  default     = "private-registry.nginx.com"
}

variable "nginx_pwd" {
  type        = string
  description = "Password for NGINX (if required)"
  default     = "none"
}

variable "workspace_path" {
  description = "The path to the workspace directory"
  type        = string
}

variable "nginx_jwt" {
  description = "The JWT token for NGINX"
  type        = string
  sensitive   = true  # Mark as sensitive to avoid exposing it in logs
}

variable "GCP_REGION" {
  description = "GCP region name"
  type        = string
}

variable "GCP_BUCKET_NAME" {
  description = "GCP bucket name"
  type    = string
}