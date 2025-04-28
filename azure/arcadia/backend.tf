terraform {
  backend "azurerm" {
    key  = "arcadia/terraform.tfstate"
  }
}