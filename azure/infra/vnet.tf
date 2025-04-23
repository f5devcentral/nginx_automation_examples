# Declare the random_id resource to generate a suffix
resource "random_id" "build_suffix" {
  byte_length = 8
}
# Create Virtual network
resource "azurerm_virtual_network" "az_vnet" {
  name                = format("%s-vnet-%s", var.project_prefix, random_id.build_suffix.hex)
  address_space       = var.azure_vnet_cidr
  location            = var.azure_region
  resource_group_name = var.resource_group_name
}
# Create Subnet
resource "azurerm_subnet" "az_subnet" {
  name                 = format("%s-subnet-%s", var.project_prefix, random_id.build_suffix.hex)
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.az_vnet.name
  address_prefixes     = var.azure_subnet_cidr
}