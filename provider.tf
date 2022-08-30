locals {
  managed_service_provider_tenant_id = "655f0684-29ae-466e-8324-2ab22497254f"
}

provider "azurerm" {
  features {}
  alias           = "citadel"
  subscription_id = "2d31be49-d959-4415-bb65-8aec2c90ba62"

  tenant_id     = local.managed_service_provider_tenant_id
  client_id     = data.azurerm_key_vault_secret.client_id.value
  client_secret = data.azurerm_key_vault_secret.client_secret.value
}

provider "azurerm" {
  features {}
  alias           = "lighthouse"
  subscription_id = "4627c0de-7ba5-4d06-8cd4-2104632e8f59"

  tenant_id     = local.managed_service_provider_tenant_id
  client_id     = data.azurerm_key_vault_secret.client_id.value
  client_secret = data.azurerm_key_vault_secret.client_secret.value
}
