output "management_groups" {
  value = var.enable_management_groups ? {
    org           = azurerm_management_group.org[0].id
    platform      = azurerm_management_group.platform[0].id
    landing_zones = azurerm_management_group.landing_zones[0].id
    sandbox       = azurerm_management_group.sandbox[0].id
  } : {}
}

output "resource_groups" {
  value = { for k, rg in azurerm_resource_group.this : k => rg.name }
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "spoke_dev_vnet_id" {
  value = azurerm_virtual_network.spoke_dev.id
}

output "spoke_prod_vnet_id" {
  value = azurerm_virtual_network.spoke_prod.id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.central.id
}

output "entra_group_ids" {
  value     = local.group_object_ids
  sensitive = false
}

output "policy_demo" {
  value = "Créer une Public IP (scripts/demo-deny-public-ip.ps1) : Azure Policy doit refuser le déploiement."
}
