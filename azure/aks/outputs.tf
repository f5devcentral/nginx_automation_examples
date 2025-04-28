output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
  sensitive = true
}
output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
  sensitive = true
}
output "aks_host" {
  value = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive = true
}
output "cluster_ca_certificate" {
  value = data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive = true
}
output "token" {
  value = data.azurerm_kubernetes_cluster.aks.kube_config[0].password
  sensitive = true
}