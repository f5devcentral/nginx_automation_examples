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

# nap/variables.tf
variable "project_prefix" {
  type = string
}

variable "build_suffix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}
