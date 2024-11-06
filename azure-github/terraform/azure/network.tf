resource "azurerm_virtual_network" "kubefirst" {
  address_space       = ["10.52.0.0/16"]
  location            = azurerm_resource_group.kubefirst.location
  name                = local.cluster_name
  resource_group_name = azurerm_resource_group.kubefirst.name

  tags = local.tags
}

resource "azurerm_subnet" "kubefirst" {
  address_prefixes     = ["10.52.0.0/24"]
  name                 = local.cluster_name
  resource_group_name  = azurerm_resource_group.kubefirst.name
  virtual_network_name = azurerm_virtual_network.kubefirst.name
}
