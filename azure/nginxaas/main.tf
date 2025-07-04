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


# Step 1: Check if the NGINX provider is already registered using Azure CLI
data "external" "nginx_provider_check" {
  program = [
    "bash", "-c",
    <<-EOT
      PROVIDER_STATUS=$(az provider show --namespace NGINX.NGINXPLUS --query "registrationState" -o tsv)
      # Output in proper JSON format for Terraform
      if [ "$PROVIDER_STATUS" == "Registered" ]; then
        echo '{"is_registered": "true"}'
      else
        echo '{"is_registered": "false"}'
      fi
    EOT
  ]
}

# Step 2: Conditionally apply the registration resource based on the check
resource "azurerm_resource_provider_registration" "nginx" {
  count = data.external.nginx_provider_check.result["is_registered"] == "false" ? 1 : 0

  name = "NGINX.NGINXPLUS"
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
