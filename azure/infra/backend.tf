terraform {
  backend "azurerm" {
    key  = "infra/terraform.tfstate"
  }
}
