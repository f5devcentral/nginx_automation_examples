# Root module variables.tf
variable "project_prefix" {
  type        = string
  description = "Prefix for all resources"
}

variable "resource_owner" {
  type        = string
  description = "Owner of the resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "create_nat_gateway" {
  type        = bool
  description = "Whether to create a NAT gateway"
  default     = false
}

variable "admin_src_addr" {
  type        = string
  description = "Admin source IP address"
  default     = "0.0.0.0/0"
}

variable "mgmt_address_prefixes" {
  type        = list(string)
  description = "Management subnet address prefixes"
}

variable "ext_address_prefixes" {
  type        = list(string)
  description = "External subnet address prefixes"
}

variable "int_address_prefixes" {
  type        = list(string)
  description = "Internal subnet address prefixes"
}

variable "nap" {
  type        = bool
  description = "Enable NAP"
}

variable "nic" {
  type        = bool
  description = "Enable NIC"
}