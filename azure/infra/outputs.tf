output "vnet_name" {
  value       = azurerm_virtual_network.az_vnet.name
  description = "Azure Virtual Network Name"
}

output "subnet_name" {
  value       = azurerm_subnet.az_subnet.name
  description = "Azure Subnet Name"
}

output "vnet_id" {
  value       = azurerm_virtual_network.az_vnet.id
  description = "Azure Vnet ID"
}

output "subnet_id" {
  value       = azurerm_subnet.az_subnet.id
  description = "Azure Subnet ID"
}

output "azure_vnet_cidr" {
  value = var.azure_vnet_cidr
}

output "azure_subnet_cidr" {
  value = var.azure_subnet_cidr
}
output "build_suffix" {
  value = random_id.build_suffix.hex
}