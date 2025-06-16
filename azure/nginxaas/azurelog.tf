#logging
resource "azurerm_log_analytics_workspace" "nginx_logging" {
  name                = "${var.project_prefix}-azure-log"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "nginx_diagnostics" {
  name                       = "${var.project_prefix}-nginx-logs"
  target_resource_id         = azurerm_nginx_deployment.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.nginx_logging.id

  enabled_log {
    category = "NginxLogs"
  }

  enabled_log {
    category = "NginxSecurityLogs"
  }

}
