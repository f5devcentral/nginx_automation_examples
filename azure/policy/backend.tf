terraform {
  backend "azurerm" {
    key  = "policy/terraform.tfstate"
  }
}