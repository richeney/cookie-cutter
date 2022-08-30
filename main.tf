module "citadel" {
  source    = "./module/cookie"
  providers = { azurerm = azurerm.citadel }
}

module "lighthouse" {
  source    = "./module/cookie"
  providers = { azurerm = azurerm.lighthouse }
}
