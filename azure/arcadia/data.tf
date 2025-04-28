# Read Infra state file
data "terraform_remote_state" "infra" {
  backend = "azurerm"
  config = {
    resource_group_name = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name = var.container_name
    key    = "infra/terraform.tfstate"
  }
}

# Read AKS state file
data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    resource_group_name = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name = var.container_name
    key    = "aks/terraform.tfstate"
  }
}

# Read nap state file
data "terraform_remote_state" "nap" {
  backend = "azurerm"
  config = {
    resource_group_name = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name = var.container_name
    key    = "nap/terraform.tfstate"
  }
}

# Read policy state file
data "terraform_remote_state" "policy" {
  backend = "azurerm"
  config = {
    resource_group_name = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name = var.container_name
    key    = "policy/terraform.tfstate"
  }
}