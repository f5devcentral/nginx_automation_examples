# Create Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.azure_region
}
# Create Storage Account
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.azure_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# Create Storage Container
resource "azurerm_storage_container" "storage_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}