provider "azurerm" {
  features {}
  subscription_id = jsondecode(var.azure_credentials)["subscriptionId"]
  client_id       = jsondecode(var.azure_credentials)["clientId"]
  client_secret   = jsondecode(var.azure_credentials)["clientSecret"]
  tenant_id       = jsondecode(var.azure_credentials)["tenantId"]
}
provider "azuread" {
  tenant_id = jsondecode(var.azure_credentials)["tenantId"]
}