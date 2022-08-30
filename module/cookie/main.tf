resource "azurerm_resource_group" "example" {
  name     = "cookie-cutter"
  location = "UK South"
}

resource "azurerm_ssh_public_key" "example" {
  name                = "example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  public_key          = file("~/.ssh/id_rsa.pub")
}

output "ssh_key" {
  value = azurerm_ssh_public_key.example.id
}
