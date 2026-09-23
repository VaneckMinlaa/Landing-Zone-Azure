# Sans Firewall : 0.0.0.0/0 -> None (pas de sortie Internet directe, inspection simulée au hub).
# Avec Firewall : 0.0.0.0/0 -> VirtualAppliance (IP privée du firewall).
locals {
  default_next_hop_type = var.enable_expensive_network ? "VirtualAppliance" : "None"
  default_next_hop_ip   = var.enable_expensive_network ? azurerm_firewall.hub[0].ip_configuration[0].private_ip_address : null
}

resource "azurerm_route_table" "forced" {
  name                          = "rt-${local.prefix}-forced-weu"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.this["connectivity"].name
  bgp_route_propagation_enabled = false
  tags                          = local.tags

  route {
    name                   = "forced-default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = local.default_next_hop_type
    next_hop_in_ip_address = local.default_next_hop_ip
  }
}

resource "azurerm_subnet_route_table_association" "spoke_dev_app" {
  subnet_id      = azurerm_subnet.spoke_dev_app.id
  route_table_id = azurerm_route_table.forced.id
}

resource "azurerm_subnet_route_table_association" "spoke_dev_data" {
  subnet_id      = azurerm_subnet.spoke_dev_data.id
  route_table_id = azurerm_route_table.forced.id
}

resource "azurerm_subnet_route_table_association" "spoke_prod_app" {
  subnet_id      = azurerm_subnet.spoke_prod_app.id
  route_table_id = azurerm_route_table.forced.id
}

resource "azurerm_subnet_route_table_association" "spoke_prod_data" {
  subnet_id      = azurerm_subnet.spoke_prod_data.id
  route_table_id = azurerm_route_table.forced.id
}
