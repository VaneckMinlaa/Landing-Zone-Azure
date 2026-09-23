resource "azurerm_public_ip" "firewall" {
  count = var.enable_expensive_network ? 1 : 0

  name                = "pip-${local.prefix}-azfw-weu"
  location            = local.location
  resource_group_name = azurerm_resource_group.this["connectivity"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_firewall" "hub" {
  count = var.enable_expensive_network ? 1 : 0

  name                = "azfw-${local.prefix}-hub-weu"
  location            = local.location
  resource_group_name = azurerm_resource_group.this["connectivity"].name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  threat_intel_mode   = "Alert"
  tags                = local.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_firewall[0].id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }
}
