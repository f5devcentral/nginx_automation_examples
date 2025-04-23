data "terraform_remote_state" "infra" {
  backend = "azurerm"
  config = {
    resource_group_name = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name = var.container_name
    key    = "infra/terraform.tfstate"
  }
}

data "azurerm_kubernetes_cluster" "aks" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
}

#data "azuread_service_principal_token" "aks_token" {
#  client_id     = jsondecode(var.azure_credentials)["clientId"]
#  client_secret   = jsondecode(var.azure_credentials)["clientSecret"]
#  tenant_id     = jsondecode(var.azure_credentials)["tenantId"]
#}