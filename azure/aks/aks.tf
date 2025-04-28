resource "azurerm_kubernetes_cluster" "aks" {
  name                = format("%s-aks-%s", var.project_prefix, local.build_suffix)
  location            = var.azure_region
  resource_group_name = var.resource_group_name
  dns_prefix          = format("%s-aks-dns-%s", var.project_prefix,local.build_suffix)
  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_D2_v2"
    vnet_subnet_id      = null
    auto_scaling_enabled= false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
	network_plugin = "azure"
  }
}