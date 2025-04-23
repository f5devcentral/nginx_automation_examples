terraform {
  backend "azurerm" {
    key  = "nap/terraform.tfstate"
  }
}