locals {
  config = "cookie-cutter"
}

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

provider "azurerm" {
  features {}
  alias = "citadel"

  tenant_id       = "655f0684-29ae-466e-8324-2ab22497254f"
  subscription_id = "2d31be49-d959-4415-bb65-8aec2c90ba62"
  client_id       = data.azurerm_key_vault_secret.client_id.value
  client_secret   = data.azurerm_key_vault_secret.client_secret.value
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
  name         = "${local.config}-client-id"
}

data "azurerm_key_vault_secret" "client_secret" {
  provider     = azurerm.backend
  key_vault_id = data.azurerm_key_vault.terraform.id
  name         = "${local.config}-client-secret"
}
