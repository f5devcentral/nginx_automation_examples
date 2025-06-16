# Get current subscription (needed for role scopes)
data "azurerm_subscription" "current" {}

# Get role definition for Grafana Admin
data "azurerm_role_definition" "grafana_admin" {
  name  = "Grafana Admin"
  scope = data.azurerm_subscription.current.id
}

# Get role definition for Monitoring Reader
data "azurerm_role_definition" "monitoring_reader" {
  name  = "Monitoring Reader"
  scope = data.azurerm_subscription.current.id
}

# Create Grafana instance with system-assigned identity
resource "azurerm_dashboard_grafana" "grafana" {
  name                = "${var.project_prefix}-grafana"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  identity {
    type = "SystemAssigned"
  }

  sku                   = "Standard"
  grafana_major_version = "11"
}

# Assign Grafana Admin role to each provided user (Object IDs)
resource "azurerm_role_assignment" "grafana_admin_users" {
  for_each = toset(var.grafana_admin_object_ids)

  scope              = azurerm_dashboard_grafana.grafana.id
  role_definition_id = data.azurerm_role_definition.grafana_admin.id
  principal_id       = each.value

  depends_on = [azurerm_dashboard_grafana.grafana]
}

# Assign Grafana Admin role to Grafana's system-assigned identity
resource "azurerm_role_assignment" "grafana_admin_app" {
  scope              = azurerm_dashboard_grafana.grafana.id
  role_definition_id = data.azurerm_role_definition.grafana_admin.id
  principal_id       = azurerm_dashboard_grafana.grafana.identity[0].principal_id

  depends_on = [azurerm_dashboard_grafana.grafana]
}

# Assign Monitoring Reader role to Grafana identity for subscription, RG, and NGINX resource
resource "azurerm_role_assignment" "grafana_monitoring_permissions" {
  for_each = {
    subscription   = data.azurerm_subscription.current.id,
    resource_group = azurerm_resource_group.main.id,
    nginx          = azurerm_nginx_deployment.main.id
  }

  scope              = each.value
  role_definition_id = data.azurerm_role_definition.monitoring_reader.id
  principal_id       = azurerm_dashboard_grafana.grafana.identity[0].principal_id

  depends_on = [
    azurerm_dashboard_grafana.grafana,
    azurerm_nginx_deployment.main
  ]
}
