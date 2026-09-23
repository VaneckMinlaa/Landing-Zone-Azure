resource "azurerm_network_security_group" "hub" {
  name                = "nsg-${local.prefix}-hub-weu"
  location            = local.location
  resource_group_name = azurerm_resource_group.this["connectivity"].name
  tags                = local.tags

  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "spoke_dev" {
  name                = "nsg-${local.prefix}-spoke-dev-weu"
  location            = local.location
  resource_group_name = azurerm_resource_group.this["lz_dev"].name
  tags                = merge(local.tags, { Environment = "dev" })

  security_rule {
    name                       = "AllowHttpsFromHub"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.address_space.hub
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenySshRdpFromInternet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "spoke_prod" {
  name                = "nsg-${local.prefix}-spoke-prod-weu"
  location            = local.location
  resource_group_name = azurerm_resource_group.this["lz_prod"].name
  tags                = merge(local.tags, { Environment = "prod" })

  security_rule {
    name                       = "AllowHttpsFromHub"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.address_space.hub
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenySshRdp"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "hub_shared" {
  subnet_id                 = azurerm_subnet.hub_shared.id
  network_security_group_id = azurerm_network_security_group.hub.id
}

resource "azurerm_subnet_network_security_group_association" "hub_mgmt" {
  subnet_id                 = azurerm_subnet.hub_mgmt.id
  network_security_group_id = azurerm_network_security_group.hub.id
}

resource "azurerm_subnet_network_security_group_association" "spoke_dev_app" {
  subnet_id                 = azurerm_subnet.spoke_dev_app.id
  network_security_group_id = azurerm_network_security_group.spoke_dev.id
}

resource "azurerm_subnet_network_security_group_association" "spoke_dev_data" {
  subnet_id                 = azurerm_subnet.spoke_dev_data.id
  network_security_group_id = azurerm_network_security_group.spoke_dev.id
}

resource "azurerm_subnet_network_security_group_association" "spoke_prod_app" {
  subnet_id                 = azurerm_subnet.spoke_prod_app.id
  network_security_group_id = azurerm_network_security_group.spoke_prod.id
}

resource "azurerm_subnet_network_security_group_association" "spoke_prod_data" {
  subnet_id                 = azurerm_subnet.spoke_prod_data.id
  network_security_group_id = azurerm_network_security_group.spoke_prod.id
}
