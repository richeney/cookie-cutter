terraform {
  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "citadelterraform"
    container_name       = "cookie-cutter"
    key                  = "tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.20.0"
    }
  }
}

# Read the secrets from the keyvault using the logged in user and their RBAC role assignments

provider "azurerm" {
  features {}
  alias   = "backend"
  use_msi = false
}

data "azurerm_key_vault" "terraform" {
  provider            = azurerm.backend
  name                = "citadelterraform"
  resource_group_name = "terraform"
}

data "azurerm_key_vault_secret" "client_id" {
  provider     = azurerm.backend
  key_vault_id = data.azurerm_key_vault.terraform.id
  name         = "cookie-cutter-client-id"
}

data "azurerm_key_vault_secret" "client_secret" {
  provider     = azurerm.backend
  key_vault_id = data.azurerm_key_vault.terraform.id
  name         = "cookie-cutter-client-secret"
}
