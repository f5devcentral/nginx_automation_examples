terraform {
  required_version = "~> 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }
}

provider "azuread" {
  use_cli = true
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
