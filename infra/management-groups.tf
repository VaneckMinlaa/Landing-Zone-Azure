resource "azurerm_management_group" "org" {
  count = var.enable_management_groups ? 1 : 0

  display_name = var.org_name
  name         = "mg-${var.org_name}"
}

resource "azurerm_management_group" "platform" {
  count = var.enable_management_groups ? 1 : 0

  display_name               = "Platform"
  name                       = "mg-${var.org_name}-platform"
  parent_management_group_id = azurerm_management_group.org[0].id
}

resource "azurerm_management_group" "landing_zones" {
  count = var.enable_management_groups ? 1 : 0

  display_name               = "Landing Zones"
  name                       = "mg-${var.org_name}-landingzones"
  parent_management_group_id = azurerm_management_group.org[0].id
}

resource "azurerm_management_group" "sandbox" {
  count = var.enable_management_groups ? 1 : 0

  display_name               = "Sandbox"
  name                       = "mg-${var.org_name}-sandbox"
  parent_management_group_id = azurerm_management_group.org[0].id
}

# Compte gratuit : une seule subscription, rattachée aux Landing Zones.
# Dev / prod sont simulés par des resource groups, pas par des abonnements.
resource "azurerm_management_group_subscription_association" "lz" {
  count = var.enable_management_groups ? 1 : 0

  management_group_id = azurerm_management_group.landing_zones[0].id
  subscription_id     = data.azurerm_subscription.current.id
}
