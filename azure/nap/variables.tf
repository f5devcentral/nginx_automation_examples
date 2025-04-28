variable "azure_credentials" {
  description = "Azure credentials as a JSON string"
  type = string
}

variable "azure_region" {
  description = "Azure region for resources"
  type        = string
}

variable "project_prefix" {
  description = "unique name to identify resources"
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "container_name" {
  type = string
}


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