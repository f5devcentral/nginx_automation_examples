output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "subnet_vms_id" {
  description = "ID of the VM subnet"
  value       = azurerm_subnet.subnet_vms.id
}

output "subnet_nginxaas_id" {
  description = "ID of the NGINXaaS subnet"
  value       = azurerm_subnet.subnet_nginxaas.id
}


output "managed_identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.id
}

output "nginxaas_public_ip" {
  description = "NGINXaaS public IP address"
  value       = azurerm_public_ip.main.ip_address
}

output "nginx_deployment_id" {
  description = "ID of the NGINXaaS deployment"
  value       = azurerm_nginx_deployment.main.id
}

output "waf_status" {
  description = "WAF status of NGINXaaS deployment"
  value       = try(azurerm_nginx_deployment.main.web_application_firewall[0].status, "not configured")
}

output "vm_public_ips" {
  description = "Public IP addresses of the created VMs"
  value       = azurerm_public_ip.vm_pip[*].ip_address
}

output "vm_ssh_commands" {
  description = "SSH commands to connect to the created VMs"
  value       = [for ip in azurerm_public_ip.vm_pip : "ssh adminuser@${ip.ip_address}"]
}

output "vm_ids" {
  description = "IDs of the Azure Linux virtual machines"
  value       = [for vm in azurerm_linux_virtual_machine.nginx_vm : vm.id]
}

output "grafana_name" {
  value = azurerm_dashboard_grafana.grafana.name
}

output "grafana_url" {
  value = azurerm_dashboard_grafana.grafana.endpoint
}


output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.nginx_logging.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.nginx_logging.id
}

output "nginx_diagnostic_setting_name" {
  description = "Name of the NGINX diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.nginx_diagnostics.name
}
