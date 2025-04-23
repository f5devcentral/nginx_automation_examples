data "terraform_remote_state" "infra" {
  backend = "azurerm"
  config = {
    resource_group_name = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name = var.container_name
    key    = "infra/terraform.tfstate"
  }
}

# Read eks state from AKS
data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name = var.container_name
    key    = "aks/terraform.tfstate"
  }
}

data "kubernetes_service_v1" "nginx-service" {
  metadata {
    name      = try(format("%s-%s-controller", helm_release.nginx-plus-ingress.name, helm_release.nginx-plus-ingress.chart))
    namespace = try(helm_release.nginx-plus-ingress.namespace)
  }
}