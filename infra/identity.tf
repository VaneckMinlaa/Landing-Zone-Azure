resource "azuread_group" "this" {
  for_each = var.enable_entra_groups ? local.entra_groups : {}

  display_name     = each.value.display_name
  description      = each.value.description
  security_enabled = true
  mail_enabled     = false
}

locals {
  group_object_ids = var.enable_entra_groups ? {
    for key, grp in azuread_group.this : key => grp.object_id
  } : {}
}

# RBAC uniquement sur des groupes — jamais sur un utilisateur.
resource "azurerm_role_assignment" "platform_admins_connectivity" {
  count = var.enable_entra_groups ? 1 : 0

  scope                = azurerm_resource_group.this["connectivity"].id
  role_definition_name = "Owner"
  principal_id         = local.group_object_ids["platform_admins"]
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "platform_admins_management" {
  count = var.enable_entra_groups ? 1 : 0

  scope                = azurerm_resource_group.this["management"].id
  role_definition_name = "Owner"
  principal_id         = local.group_object_ids["platform_admins"]
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "network_ops" {
  count = var.enable_entra_groups ? 1 : 0

  scope                = azurerm_resource_group.this["connectivity"].id
  role_definition_name = "Network Contributor"
  principal_id         = local.group_object_ids["network_ops"]
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "app_devs" {
  count = var.enable_entra_groups ? 1 : 0

  scope                = azurerm_resource_group.this["lz_dev"].id
  role_definition_name = "Contributor"
  principal_id         = local.group_object_ids["app_devs"]
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "app_prod" {
  count = var.enable_entra_groups ? 1 : 0

  scope                = azurerm_resource_group.this["lz_prod"].id
  role_definition_name = "Reader"
  principal_id         = local.group_object_ids["app_prod"]
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "readers" {
  count = var.enable_entra_groups ? 1 : 0

  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = local.group_object_ids["readers"]
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "sandbox" {
  count = var.enable_entra_groups ? 1 : 0

  scope                = azurerm_resource_group.this["sandbox"].id
  role_definition_name = "Contributor"
  principal_id         = local.group_object_ids["sandbox_users"]
  principal_type       = "Group"
}
