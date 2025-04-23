provider "azurerm" {
  features {}
  subscription_id = jsondecode(var.azure_credentials)["subscriptionId"]
  client_id       = jsondecode(var.azure_credentials)["clientId"]
  client_secret   = jsondecode(var.azure_credentials)["clientSecret"]
  tenant_id       = jsondecode(var.azure_credentials)["tenantId"]
}
provider "kubernetes" {
    host = local.host
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
    token = local.token
}
provider "helm" {
    kubernetes {
        host = local.host
        cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
        token = local.token
    }
}