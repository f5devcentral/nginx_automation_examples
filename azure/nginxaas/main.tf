locals {
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "${var.project_prefix}-rg"
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.azure_region
  tags     = var.tags
}

resource "null_resource" "validate_admin_ip" {
  provisioner "local-exec" {
    command = <<EOT
      if [ -z "${var.admin_ip}" ]; then
        echo "admin_ip must be set for NSG for VM's"
        exit 1
      fi
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}


data "azurerm_resource_provider" "nginx" {
  name = "NGINX.NGINXPLUS"
}

resource "azurerm_resource_provider_registration" "nginx" {
  count = data.azurerm_resource_provider.nginx.registration_state == "Registered" ? 0 : 1
  name  = "NGINX.NGINXPLUS"
}

resource "time_sleep" "wait_1_minutes" {
  depends_on      = [azurerm_resource_provider_registration.nginx]
  create_duration = "60s"
}

resource "azurerm_user_assigned_identity" "main" {
  name                = "${var.project_prefix}-identity"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  depends_on = [azurerm_resource_group.main]
}

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_virtual_network.vnet_nginxaas.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_public_ip" "main" {
  name                = "${var.project_prefix}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nginx_deployment" "main" {
  depends_on = [
    time_sleep.wait_1_minutes,
    azurerm_role_assignment.contributor,
    azurerm_role_assignment.network_contributor,
    azurerm_subnet_network_security_group_association.nsg_assoc_vm,
    azurerm_subnet_network_security_group_association.nsg_assoc_nginxaas
  ]

  name                      = substr("${var.project_prefix}-nginxaas", 0, 40)
  resource_group_name       = azurerm_resource_group.main.name
  location                  = var.azure_region
  sku                       = var.sku
  capacity                  = var.capacity
  automatic_upgrade_channel = "stable"
  diagnose_support_enabled  = true

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  frontend_public {
    ip_address = [azurerm_public_ip.main.id]
  }

  network_interface {
    subnet_id = azurerm_subnet.subnet_nginxaas.id
  }

  web_application_firewall {
    activation_state_enabled = true
  }

  tags = var.tags
}
