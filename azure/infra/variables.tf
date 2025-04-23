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

variable "azure_vnet_cidr" {
  type        = list(string)
  default     = ["192.168.0.0/16"]
  description = "CIDR block for Vnet"
}

variable "azure_subnet_cidr" {
  type        = list(string)
  default     = ["192.168.1.0/24"]
  description = "CIDR block for Subnet"
}