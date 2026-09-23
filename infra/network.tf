resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${local.prefix}-hub-weu"
  location            = local.location
  resource_group_name = azurerm_resource_group.this["connectivity"].name
  address_space       = [var.address_space.hub]
  tags                = local.tags
}

resource "azurerm_subnet" "hub_shared" {
  name                 = "snet-shared"
  resource_group_name  = azurerm_resource_group.this["connectivity"].name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.address_space.hub, 8, 0)]
}

resource "azurerm_subnet" "hub_mgmt" {
  name                 = "snet-mgmt"
  resource_group_name  = azurerm_resource_group.this["connectivity"].name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.address_space.hub, 8, 1)]
}

resource "azurerm_subnet" "hub_firewall" {
  count = var.enable_expensive_network ? 1 : 0

  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this["connectivity"].name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.address_space.hub, 10, 8)]
}

resource "azurerm_virtual_network" "spoke_dev" {
  name                = "vnet-${local.prefix}-spoke-dev-weu"
  location            = local.location
  resource_group_name = azurerm_resource_group.this["lz_dev"].name
  address_space       = [var.address_space.spoke_dev]
  tags                = merge(local.tags, { Environment = "dev" })
}

resource "azurerm_subnet" "spoke_dev_app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.this["lz_dev"].name
  virtual_network_name = azurerm_virtual_network.spoke_dev.name
  address_prefixes     = [cidrsubnet(var.address_space.spoke_dev, 8, 1)]
}

resource "azurerm_subnet" "spoke_dev_data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.this["lz_dev"].name
  virtual_network_name = azurerm_virtual_network.spoke_dev.name
  address_prefixes     = [cidrsubnet(var.address_space.spoke_dev, 8, 2)]
}

resource "azurerm_virtual_network" "spoke_prod" {
  name                = "vnet-${local.prefix}-spoke-prod-weu"
  location            = local.location
  resource_group_name = azurerm_resource_group.this["lz_prod"].name
  address_space       = [var.address_space.spoke_prod]
  tags                = merge(local.tags, { Environment = "prod" })
}

resource "azurerm_subnet" "spoke_prod_app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.this["lz_prod"].name
  virtual_network_name = azurerm_virtual_network.spoke_prod.name
  address_prefixes     = [cidrsubnet(var.address_space.spoke_prod, 8, 1)]
}

resource "azurerm_subnet" "spoke_prod_data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.this["lz_prod"].name
  virtual_network_name = azurerm_virtual_network.spoke_prod.name
  address_prefixes     = [cidrsubnet(var.address_space.spoke_prod, 8, 2)]
}
