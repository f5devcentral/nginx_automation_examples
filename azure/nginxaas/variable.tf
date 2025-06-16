variable "project_prefix" {
  type        = string
  description = "Project prefix for resource naming (max 12 chars)"
  validation {
    condition     = length(var.project_prefix) <= 12
    error_message = "Project prefix must be 12 characters or less."
  }
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "azure_region" {
  type        = string
  description = "Azure deployment region"
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resource group name"
}

variable "grafana_admin_object_ids" {
  type        = list(string)
  description = "List of Azure AD Object IDs to assign Grafana Viewer role"
}

variable "sku" {
  type        = string
  description = "NGINXaaS SKU tier"
  default     = "standardv2_Monthly_gmz7xq9ge3py"
}

variable "capacity" {
  type        = number
  description = "NGINXaaS deployment capacity"
  default     = 10
}


variable "subnet_prefix_vms" {
  type        = string
  default     = "10.10.1.0/24"
  description = "Subnet CIDR block for VMs"
}

variable "subnet_prefix_nginxaas" {
  type        = string
  default     = "10.20.1.0/24"
  description = "Subnet CIDR block for NGINXaaS"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
  sensitive   = true
}

variable "container_name" {
  type        = string
  description = "Azure storage container name for Terraform state"
  default     = "terraform-state"
}

variable "admin_ip" {
  type        = string
  description = "Current admin IP for SSH access (IPv4 without /32 suffix)"
  default     = ""
}
