variable "azure_credentials" {
  description = "Azure credentials as a JSON string"
  type = string
}

variable "azure_region" {
  description = "Azure region for resources"
  type        = string
}

variable "project_prefix" {
  description = "Unique name to identify the created resources"
  type = string
}

variable "resource_group_name" {
  description = "Resource group name where all the resources will be deployed"
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "container_name" {
  type = string
}