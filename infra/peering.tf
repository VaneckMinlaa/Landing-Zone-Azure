resource "azurerm_virtual_network_peering" "hub_to_dev" {
  name                         = "peer-hub-to-spoke-dev"
  resource_group_name          = azurerm_resource_group.this["connectivity"].name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_dev.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "dev_to_hub" {
  name                         = "peer-spoke-dev-to-hub"
  resource_group_name          = azurerm_resource_group.this["lz_dev"].name
  virtual_network_name         = azurerm_virtual_network.spoke_dev.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub_to_prod" {
  name                         = "peer-hub-to-spoke-prod"
  resource_group_name          = azurerm_resource_group.this["connectivity"].name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_prod.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "prod_to_hub" {
  name                         = "peer-spoke-prod-to-hub"
  resource_group_name          = azurerm_resource_group.this["lz_prod"].name
  virtual_network_name         = azurerm_virtual_network.spoke_prod.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}
