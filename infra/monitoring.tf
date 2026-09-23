resource "azurerm_log_analytics_workspace" "central" {
  name                = "log-${local.prefix}-central-weu"
  location            = local.location
  resource_group_name = azurerm_resource_group.this["management"].name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 1
  tags                = local.tags
}

resource "azurerm_monitor_action_group" "platform" {
  name                = "ag-${local.prefix}-platform"
  resource_group_name = azurerm_resource_group.this["management"].name
  short_name          = "platops"
  tags                = local.tags

  email_receiver {
    name                    = "security-contact"
    email_address           = var.security_contact_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "activity" {
  name                       = "diag-activity-to-law"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.central.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Policy"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_hub" {
  name                       = "diag-nsg-hub"
  target_resource_id         = azurerm_network_security_group.hub.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.central.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_dev" {
  name                       = "diag-nsg-dev"
  target_resource_id         = azurerm_network_security_group.spoke_dev.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.central.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_prod" {
  name                       = "diag-nsg-prod"
  target_resource_id         = azurerm_network_security_group.spoke_prod.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.central.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}
