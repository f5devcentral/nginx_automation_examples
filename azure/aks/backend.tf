terraform {
  backend "azurerm" {
    key  = "aks/terraform.tfstate"
  }
}